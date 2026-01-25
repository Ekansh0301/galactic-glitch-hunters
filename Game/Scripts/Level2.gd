extends Node2D

# --- ASSETS ---
var texture_flying = preload("res://Assets/isolated-rocket-transparent.png")
var texture_landed = preload("res://Assets/nve9_twbd_210520-Photoroom.png")

# --- TUNING SETTINGS ---
var SCALE_ROCKET = Vector2(0.20, 0.20)   
var SCALE_HUMAN_START = Vector2(0.45, 0.45) 
var SCALE_HUMAN_END   = Vector2(0.65, 0.65) 
var SCALE_ROBOT       = Vector2(0.65, 0.65) 

var LANDING_X = 750
var GROUND_Y  = 350
var SPAWN_Y   = 380 

# Trackers to kill animations
var hero_tween: Tween
var nova_tween: Tween

func _ready():
	# --- 1. HIDE BUBBLES IMMEDIATELY ---
	if has_node("Nova/Bubble"): $Nova/Bubble.visible = false
	if has_node("Robot/Bubble"): $Robot/Bubble.visible = false

	# --- 2. GENDER LOGIC ---
	var nova_gender = "female"
	if has_node("/root/GameManager"):
		if get_node("/root/GameManager").get("selected_nova"):
			nova_gender = get_node("/root/GameManager").selected_nova
	
	if has_node("Nova"):
		var n = $Nova
		if n.has_node("Nova_Male"): n.get_node("Nova_Male").visible = false
		if n.has_node("Nova_Female"): n.get_node("Nova_Female").visible = false
		if nova_gender == "male" and n.has_node("Nova_Male"): n.get_node("Nova_Male").visible = true
		elif n.has_node("Nova_Female"): n.get_node("Nova_Female").visible = true

	# --- 3. APPLY SIZES ---
	if has_node("RocketShip"): $RocketShip.scale = SCALE_ROCKET
	if has_node("Hero"):       $Hero.scale = SCALE_HUMAN_START
	if has_node("Nova"):       $Nova.scale = SCALE_HUMAN_START
	if has_node("Robot"):      $Robot.scale = SCALE_ROBOT

	# --- 4. SETUP POSITIONS ---
	if has_node("Camera2D"):
		$Camera2D.position = Vector2(LANDING_X, 324)
		$Camera2D.zoom = Vector2(1.8, 1.8) 
	
	if has_node("Robot"):
		$Robot.position = Vector2(200, 350)
		$Robot.visible = false 
	if has_node("Hero"): $Hero.visible = false
	if has_node("Nova"): $Nova.visible = false

	var rocket = $RocketShip
	rocket.position = Vector2(LANDING_X, -500)
	rocket.texture = texture_flying
	
	land_rocket()

# --- MOVEMENT SEQUENCE ---

func land_rocket():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($RocketShip, "position:y", GROUND_Y, 4.0)
	tween.finished.connect(_on_touchdown)

func _on_touchdown():
	$RocketShip.texture = texture_landed
	if has_node("Camera2D"):
		var camera = $Camera2D
		var shake = create_tween()
		for i in 5:
			shake.tween_property(camera, "offset", Vector2(0, 5), 0.05)
			shake.tween_property(camera, "offset", Vector2(0, -5), 0.05)
		shake.tween_property(camera, "offset", Vector2(0, 0), 0.05)
	
	get_tree().create_timer(1.0).timeout.connect(spawn_crew)

func spawn_crew():
	if has_node("Hero"):
		$Hero.visible = true
		$Hero.position = Vector2(LANDING_X, SPAWN_Y) 
	if has_node("Nova"):
		$Nova.visible = true
		$Nova.position = Vector2(LANDING_X + 40, SPAWN_Y) 
	
	get_tree().create_timer(1.0).timeout.connect(start_confrontation)

func start_confrontation():
	if has_node("Robot"): $Robot.visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Pan Camera
	if has_node("Camera2D"):
		tween.tween_property($Camera2D, "position:x", 576.0, 4.0)
		tween.tween_property($Camera2D, "zoom", Vector2(1.0, 1.0), 4.0)
	
	# Rocket Exit
	if has_node("RocketShip"):
		tween.tween_property($RocketShip, "position:x", 1500.0, 4.0)

	# Actors Move & Grow
	if has_node("Hero"):
		tween.tween_property($Hero, "position:x", 650.0, 4.0) 
		tween.tween_property($Hero, "scale", SCALE_HUMAN_END, 4.0)
		# Save Tween to variable
		hero_tween = _animate_walk($Hero) 
		
	if has_node("Nova"):
		tween.tween_property($Nova, "position:x", 720.0, 4.0)
		tween.tween_property($Nova, "scale", SCALE_HUMAN_END, 4.0)
		# Save Tween to variable
		nova_tween = _animate_walk($Nova) 
	
	tween.chain().tween_callback(_on_scene_ready)

func _animate_walk(node) -> Tween:
	var waddle = create_tween()
	waddle.set_loops(10) 
	waddle.tween_property(node, "rotation", 0.05, 0.2)
	waddle.parallel().tween_property(node, "position:y", node.position.y - 10, 0.2)
	waddle.tween_property(node, "rotation", -0.05, 0.2)
	waddle.parallel().tween_property(node, "position:y", node.position.y, 0.2)
	return waddle

# --- DIALOGUE & POSITIONING ---

func _on_scene_ready():
	print("Movement done. KILLING TILT & Starting Bubbles.")
	
	# --- THE TILT FIX ---
	# 1. Kill the active animations immediately
	if hero_tween: hero_tween.kill()
	if nova_tween: nova_tween.kill()
	
	# 2. Force rotation to 0.0 (Upright)
	if has_node("Hero"): $Hero.rotation = 0.0
	if has_node("Nova"): $Nova.rotation = 0.0
	
	if has_node("RocketShip"): $RocketShip.visible = false 
	run_dialogue_sequence()

func run_dialogue_sequence():
	# 1. Nova Speaks
	if has_node("Nova/Bubble"):
		var bubble = $Nova/Bubble
		bubble.position = Vector2(95, -190) 
		bubble.text = "Hostile signal detected!"
		bubble.visible = true
		
		# REDUCED TIME: 2.0 Seconds
		await get_tree().create_timer(2.0).timeout
		bubble.visible = false
	
	# 2. Robot Speaks
	if has_node("Robot/Bubble"):
		var bubble = $Robot/Bubble
		bubble.position = Vector2(60, -190)
		bubble.text = "UNIDENTIFIED LIFE FORM.\nELIMINATE."
		bubble.visible = true
		
		# REDUCED TIME: 2.0 Seconds
		await get_tree().create_timer(2.0).timeout
		bubble.visible = false
	
	# 3. Transition
	zoom_into_pov()

func zoom_into_pov():
	print("Transitioning to POV...")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN)
	
	if has_node("Camera2D"):
		# Zoom REALLY close to Hero's face
		tween.tween_property($Camera2D, "zoom", Vector2(5.0, 5.0), 1.5)
		tween.parallel().tween_property($Camera2D, "position", Vector2(650, 350), 1.5)
		
	tween.finished.connect(_change_to_pov_scene)

func _change_to_pov_scene():
	print("SCENE CHANGE GOES HERE")
	get_tree().change_scene_to_file("res://Scenes/BattleScene.tscn")