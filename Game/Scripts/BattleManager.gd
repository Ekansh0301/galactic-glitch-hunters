extends Node2D

# Dynamic loading - no preload needed
const BALLOON_SCENE = preload("res://Scenes/GameBalloon.tscn")

@onready var nova = $Nova
@onready var robot = $Robot
@onready var background = $Background

# Current scenario data
var current_scenario = null
var dialogue_resource = null 
var was_correct: bool = false

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
		get_tree().change_scene_to_file("res://Scenes/hub_new.tscn")
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
	# Now Nova is always Female!
	if nova.has_node("Nova_Male"): nova.get_node("Nova_Male").visible = false
	if nova.has_node("Nova_Female"): nova.get_node("Nova_Female").visible = true

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

# --- VIDEO OVERLAYS for wrong/violent choices ---

const REJECT_VIDEO_PATH = "res://Assets/videos/reject.ogv"
const ANGER_VIDEO_PATH  = "res://Assets/videos/anger.ogv"

## Plays the "reject" video (wrong/submissive option). Awaitable by Dialogue Manager.
func play_reject_video() -> void:
	await _play_choice_video(REJECT_VIDEO_PATH)

## Plays the "anger" video (violent option). Awaitable by Dialogue Manager.
func play_anger_video() -> void:
	await _play_choice_video(ANGER_VIDEO_PATH)

## Internal helper: creates a fullscreen overlay, plays `video_path`, awaits completion.
func _play_choice_video(video_path: String) -> void:
	var stream = load(video_path)
	if stream == null:
		push_error("BattleManager: Could not load video: " + video_path)
		return

	# Build a CanvasLayer overlay (layer 200) so it sits above the dialogue balloon.
	var canvas = CanvasLayer.new()
	canvas.layer = 200
	get_tree().current_scene.add_child(canvas)

	# black_bg and vsp are Control nodes — they have modulate we can tween later.
	var black_bg = ColorRect.new()
	black_bg.color = Color(0, 0, 0, 1)
	black_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(black_bg)

	var vsp = VideoStreamPlayer.new()
	vsp.stream = stream
	vsp.expand = true
	vsp.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(vsp)

	vsp.play()

	# Short cooldown so the keypress that chose this option doesn't instantly skip.
	await get_tree().create_timer(0.4).timeout

	# Loop until video finishes naturally (is_playing() → false) or player skips.
	# NOTE: GDScript 4 lambdas capture by value, so we avoid them here and rely
	# purely on is_playing() as the exit condition. vsp.stop() is called on skip
	# which causes is_playing() to return false on the next frame.
	while vsp.is_playing():
		await get_tree().process_frame
		if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_ESCAPE):
			vsp.stop()   # breaks the loop on next frame

	# Fade out the child Controls (CanvasLayer itself has no modulate property).
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(black_bg, "modulate:a", 0.0, 0.4)
	tween.tween_property(vsp,      "modulate:a", 0.0, 0.4)
	await tween.finished

	canvas.queue_free()

# --- ACTIONS ---

func handle_correct():
	was_correct = true
	if has_node("/root/GameState"):
		GameState.correct_answers_this_run += 1
		GameState.add_score(100)
		GameState.shift_bias(-20) # Lower bias
	update_ui()

func handle_wrong():
	was_correct = false
	GameState.shift_bias(20) # Penalize
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
	
	if was_correct:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/CorrectAnswerCutscene.tscn")
	else:
		if has_more:
			# More scenarios to go - return to loading screen
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
		else:
			# Mission complete
			await get_tree().create_timer(1.0).timeout
			
			# Go to the lesson scene after the 3 scenarios of the current run are completed
			get_tree().change_scene_to_file("res://Scenes/LessonScreen.tscn")

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
