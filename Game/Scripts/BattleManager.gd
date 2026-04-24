extends Node2D

# Dynamic loading - no preload needed
const BALLOON_SCENE = preload("res://Scenes/GameBalloon.tscn")

@onready var nova = $Nova
@onready var robot = $Robot
@onready var background = $Background

# Current scenario data
var current_scenario = null
var dialogue_resource = null 

# HUD Paths
@onready var bias_meter = $HUD/ProgressBar
@onready var score_label = $HUD/ScoreLabel

var _malfunction_tween: Tween

func _ready():
	print("=== BATTLEMANAGER READY ===")
	MusicManager.play_track(MusicManager.TRACK_VOLATILE_REACTION)
	
	# 1. GET CURRENT SCENARIO FROM SCENARIOMANAGER
	if not has_node("/root/ScenarioManager"):
		push_error("ScenarioManager not found in autoload!")
		return
		
	current_scenario = ScenarioManager.get_current_scenario()
	
	if current_scenario == null:
		push_error("No scenario available! Did you start a mission from the Hub?")
		push_error("Returning to Hub...")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/hub.tscn")
		return
	
	print("Current Scenario: ", current_scenario.title)
	print("Dialogue File: ", current_scenario.dialogue_file)
	
	# 2. LOAD DIALOGUE FILE (language-aware: try .hi.dialogue or .te.dialogue first)
	var dialogue_path = _get_localized_dialogue_path(current_scenario.dialogue_file)
	print("Loading dialogue: ", dialogue_path)
	dialogue_resource = load(dialogue_path)
	
	if dialogue_resource == null:
		push_error("Failed to load dialogue: " + current_scenario.dialogue_file)
		return
	
	print("Dialogue resource loaded successfully")
	
	# 3. LOAD BACKGROUND IMAGE - ONLY CHANGE TEXTURE, KEEP SCENE POSITIONING
	if current_scenario.has("background") and background:
		var bg_texture = load(current_scenario.background)
		if bg_texture:
			background.texture = bg_texture
			print("Background loaded: ", current_scenario.background)
			# Don't touch position, scale, anchors, offsets - keep original scene layout
	
	# 4. SETUP VISUALS (Start Invisible)
	nova.visible = true
	robot.visible = true
	nova.modulate = Color(1, 1, 1, 0)
	robot.modulate = Color(1, 1, 1, 0)
	
	if has_node("/root/GameState"):
		update_ui()
	
	# 5. GENDER LOGIC
	var chosen_nova = "female"
	if has_node("/root/GameManager"):
		chosen_nova = get_node("/root/GameManager").selected_nova
	
	print("Nova gender selected: ", chosen_nova)
	
	if nova.has_node("Nova_Male"): nova.get_node("Nova_Male").visible = (chosen_nova == "male")
	if nova.has_node("Nova_Female"): nova.get_node("Nova_Female").visible = (chosen_nova == "female")

	# 6. START INTRO
	print("Starting intro sequence...")
	start_intro_sequence()

func start_intro_sequence():
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(nova, "modulate:a", 1.0, 1.5)
	tween.tween_property(robot, "modulate:a", 1.0, 1.5)
	
	tween.tween_property(nova, "position:x", nova.position.x - 20, 1.5).from(nova.position.x + 20)
	tween.tween_property(robot, "position:x", robot.position.x + 20, 1.5).from(robot.position.x - 20)
	
	tween.chain().tween_callback(spawn_dialogue)

func spawn_dialogue():
	print("=== SPAWNING DIALOGUE ===")
	print("Dialogue resource: ", dialogue_resource)
	
	if dialogue_resource == null:
		push_error("Cannot spawn dialogue - resource is null!")
		return
		
	var balloon = BALLOON_SCENE.instantiate()
	get_tree().current_scene.add_child(balloon)
	print("Balloon added to scene, starting dialogue...")
	balloon.start(dialogue_resource, "start", [self])

func update_ui():
	if has_node("/root/GameState"):
		# Animate score update
		var current_text = score_label.text
		var current_val = int(current_text.split(": ")[1]) if ": " in current_text else 0
		var tween_score = create_tween()
		tween_score.tween_method(func(val): 
			score_label.text = LanguageManager.t("score_label") + str(int(val)),
			current_val, GameState.score, 0.5)
		
		# Smooth animate bias meter
		var tween_bias = create_tween()
		tween_bias.set_ease(Tween.EASE_OUT)
		tween_bias.set_trans(Tween.TRANS_CUBIC)
		tween_bias.tween_property(bias_meter, "value", GameState.bias_meter, 0.4)
		
		# Pulse warning if extreme bias
		if GameState.bias_meter < 20 or GameState.bias_meter > 80:
			var original_scale = bias_meter.scale
			var tween_pulse = create_tween()
			tween_pulse.set_loops(2)
			tween_pulse.tween_property(bias_meter, "scale", original_scale * 1.1, 0.2)
			tween_pulse.tween_property(bias_meter, "scale", original_scale, 0.2)

func _trigger_malfunction(duration: float = 0.26, radius: float = 6.0, frame_time: float = 0.04):
	if robot == null:
		return

	if is_instance_valid(_malfunction_tween):
		_malfunction_tween.kill()

	var original_offset: Vector2 = robot.offset
	var original_modulate: Color = robot.modulate
	var step_count: int = maxi(2, int(round(duration / frame_time)))

	_malfunction_tween = create_tween()
	for i in range(step_count):
		var step: int = i
		_malfunction_tween.tween_callback(func():
			robot.offset = original_offset + Vector2(
				randf_range(-radius, radius),
				randf_range(-radius, radius)
			)
			if step % 2 == 0:
				robot.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				robot.modulate = Color(1.0, 0.25, 0.25, 1.0)
		)
		_malfunction_tween.tween_interval(frame_time)

	_malfunction_tween.tween_callback(func():
		robot.offset = original_offset
		robot.modulate = original_modulate
	)

# --- ACTIONS ---

func handle_correct():
	GameState.add_score(100)
	GameState.shift_bias(-20) # Lower bias
	
	# Green Flash (Extended Version)
	var tween = create_tween()
	
	# 1. Turn Bright Green (0.4 seconds)
	tween.tween_property(robot, "modulate", Color(0.3, 1, 0.3), 0.4)
	
	# 2. Stay Green for a moment (Hold for 0.4 seconds)
	tween.tween_interval(0.4)
	
	# 3. Fade back to Normal (0.4 seconds)
	tween.tween_property(robot, "modulate", Color(1, 1, 1), 0.4)
	
	update_ui()

func handle_wrong():
	GameState.shift_bias(20) # Penalize

	# Malfunction feedback: jitter + alternating white/red flashes.
	_trigger_malfunction()
	
	update_ui()

# --- THE CINEMATIC MOMENT (Fixed: Move Left/Up to Center Her) ---
func trigger_nova_explanation():
	# 1. Pop Nova to the Front Layer
	nova.z_index = 10 
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 2. Dim the Robot and Background
	tween.tween_property(robot, "modulate", Color(0.3, 0.3, 0.3, 1), 0.5)
	tween.tween_property(background, "modulate", Color(0.3, 0.3, 0.3, 1), 0.5)
	
	# 3. Highlight Nova (Bright White)
	tween.tween_property(nova, "modulate", Color(1, 1, 1, 1), 0.5)

	# Keep Nova anchored in-place to avoid unintended drift after wrong answers.
	tween.tween_property(nova, "scale", Vector2(1.05, 1.05), 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(nova, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_CUBIC)

func resolve_battle():
	print("Scenario End. Checking for more scenarios...")
	
	# Mark current scenario as complete
	var has_more = ScenarioManager.complete_current_scenario()
	
	if has_more:
		# More scenarios to go - return to loading screen
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
	else:
		# Mission complete - return to Hub
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/hub.tscn")

# ============================================================
# Load a language-specific .dialogue file if it exists,
# otherwise fall back to the English original.
# e.g. scenario_07_emotions.dialogue → scenario_07_emotions.hi.dialogue
# ============================================================
func _get_localized_dialogue_path(base_path: String) -> String:
	var lang = "en"
	if has_node("/root/LanguageManager"):
		lang = get_node("/root/LanguageManager").current_language
	if lang != "en":
		var lang_path = base_path.replace(".dialogue", "." + lang + ".dialogue")
		if ResourceLoader.exists(lang_path):
			return lang_path
	return base_path
