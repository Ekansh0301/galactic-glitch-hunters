extends Node2D

const DIALOGUE_RESOURCE = preload("res://Dialogue/battle.dialogue")
const BALLOON_SCENE = preload("res://Scenes/GameBalloon.tscn")

@onready var nova = $Nova
@onready var robot = $Robot
# Ensure your Background node is named "Background" in the Scene Tree!
@onready var background = $Background 

# HUD Paths
@onready var bias_meter = $HUD/ProgressBar
@onready var score_label = $HUD/ScoreLabel

func _ready():
	# 1. SETUP VISUALS (Start Invisible)
	nova.visible = true
	robot.visible = true
	nova.modulate = Color(1, 1, 1, 0)
	robot.modulate = Color(1, 1, 1, 0)
	
	if has_node("/root/GameState"):
		update_ui()
	
	# 2. GENDER LOGIC
	var chosen_nova = "female"
	if has_node("/root/GameManager"):
		chosen_nova = get_node("/root/GameManager").selected_nova
	
	if nova.has_node("Nova_Male"): nova.get_node("Nova_Male").visible = (chosen_nova == "male")
	if nova.has_node("Nova_Female"): nova.get_node("Nova_Female").visible = (chosen_nova == "female")

	# 3. START INTRO
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
	var balloon = BALLOON_SCENE.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(DIALOGUE_RESOURCE, "start", [self])

func update_ui():
	if has_node("/root/GameState"):
		score_label.text = "Score: " + str(GameState.score)
		bias_meter.value = GameState.bias_meter

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
	
	# Red Flash, Shake, & Glitch Blur
	var tween = create_tween()
	tween.set_parallel(true)
	# Turn angry Red
	tween.tween_property(robot, "modulate", Color(1, 0, 0), 0.2)
	# Shake X position
	tween.tween_property(robot, "position:x", robot.position.x + 15, 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.chain().tween_property(robot, "position:x", robot.position.x - 15, 0.05)
	
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
	
	# 4. THE MOVE: Left, Up, and Zoom
	# 'as_relative()' means "Move from current spot"
	
	# Move LEFT (-x) towards the center of the screen
	tween.tween_property(nova, "position:x", -400.0, 0.8).as_relative().set_trans(Tween.TRANS_CUBIC)
	
	# Move UP (-y) so she dominates the view
	tween.tween_property(nova, "position:y", -300.0, 0.8).as_relative().set_trans(Tween.TRANS_CUBIC)
	
	# Zoom In
	tween.tween_property(nova, "scale", Vector2(1.3, 1.3), 0.8).set_trans(Tween.TRANS_CUBIC)

func resolve_battle():
	print("Scenario End. Loading next...")
	# Placeholder for loading the next scene
	# get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")