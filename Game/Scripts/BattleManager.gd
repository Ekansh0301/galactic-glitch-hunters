extends Node2D

const DIALOGUE_RESOURCE = preload("res://Dialogue/battle.dialogue")
const BALLOON_SCENE = preload("res://Scenes/GameBalloon.tscn")

@onready var nova = $Nova
@onready var robot = $Robot

# HUD Paths (Updated to match your screenshot)
@onready var bias_meter = $HUD/ProgressBar
@onready var score_label = $HUD/ScoreLabel

func _ready():
	# 1. FORCE VISIBILITY & TRANSPARENCY
	# This ensures they exist but are invisible (alpha = 0)
	nova.visible = true
	robot.visible = true
	nova.modulate = Color(1, 1, 1, 0)
	robot.modulate = Color(1, 1, 1, 0)
	
	# 2. SYNC UI
	if has_node("/root/GameState"):
		update_ui()
	
	# 3. GENDER LOGIC
	var chosen_nova = "female"
	if has_node("/root/GameManager"):
		chosen_nova = get_node("/root/GameManager").selected_nova
	
	if nova.has_node("Nova_Male"): nova.get_node("Nova_Male").visible = (chosen_nova == "male")
	if nova.has_node("Nova_Female"): nova.get_node("Nova_Female").visible = (chosen_nova == "female")

	# 4. START INTRO
	start_intro_sequence()

func start_intro_sequence():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade Alpha to 1.0 (Fully Visible)
	tween.tween_property(nova, "modulate:a", 1.0, 1.5)
	tween.tween_property(robot, "modulate:a", 1.0, 1.5)
	
	# Slide in logic
	tween.tween_property(nova, "position:x", nova.position.x - 20, 1.5).from(nova.position.x + 20)
	tween.tween_property(robot, "position:x", robot.position.x + 20, 1.5).from(robot.position.x - 20)
	
	tween.chain().tween_callback(spawn_dialogue)

func spawn_dialogue():
	var balloon = BALLOON_SCENE.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(DIALOGUE_RESOURCE, "start", [self])

func update_ui():
	# Update Global UI
	if has_node("/root/GameState"):
		score_label.text = "Score: " + str(GameState.score)
		bias_meter.value = GameState.bias_meter

# --- ACTIONS CALLED BY DIALOGUE ---

func handle_correct():
	GameState.add_score(100)
	GameState.shift_bias(-20) # Lower bias = Logic Win
	
	# Green Flash
	var tween = create_tween()
	tween.tween_property(robot, "modulate", Color(0.5, 1, 0.5), 0.2)
	tween.tween_property(robot, "modulate", Color(1, 1, 1), 0.2)
	
	update_ui()

func handle_wrong():
	GameState.shift_bias(20) # Higher bias = Glitch Win
	
	# Red Flash & Shake
	var tween = create_tween()
	tween.tween_property(robot, "modulate", Color(1, 0, 0), 0.2)
	tween.tween_property(robot, "position:x", robot.position.x + 10, 0.05).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(robot, "position:x", robot.position.x - 10, 0.05)
	
	update_ui()

func resolve_battle():
	print("Level Complete! Switching scenes...")
	# Scene transition logic goes here