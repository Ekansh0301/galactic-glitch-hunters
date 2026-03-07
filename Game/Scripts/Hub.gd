extends Control

# UI References - Made optional in case nodes don't exist in scene
@onready var name_label = $TopBar/PlayerNameLabel if has_node("TopBar/PlayerNameLabel") else null
@onready var rank_label = $TopBar/RankLabel if has_node("TopBar/RankLabel") else null
@onready var score_label = $MainDisplay/VBoxContainer/TotalScoreLabel if has_node("MainDisplay/VBoxContainer/TotalScoreLabel") else null
@onready var bias_meter = $MainDisplay/VBoxContainer/BiasMeter if has_node("MainDisplay/VBoxContainer/BiasMeter") else null

func _ready():
	print("=== HUB LOADED ===")
	print("Player Name: ", GameManager.player_name)
	print("Current Rank: ", GameManager.current_rank)
	print("Total Score: ", GameManager.total_score)
	
	# AUTO-CONNECT START MISSION BUTTON
	_connect_start_button()
	
	var LM = get_node("/root/LanguageManager")

	# Populate UI with data from GameManager on entry
	if name_label:
		name_label.text = LM.t("hub_cadet") + GameManager.player_name
	else:
		print("WARNING: name_label not found")
		
	if rank_label:
		rank_label.text = LM.t("hub_rank") + GameManager.current_rank
	else:
		print("WARNING: rank_label not found")
		
	if score_label:
		score_label.text = LM.t("hub_score") + str(GameManager.total_score)
	else:
		print("WARNING: score_label not found")
	
	# Show scenarios completed count
	var completed = AuthManager.get_scenarios_completed_count()
	if has_node("MainDisplay/VBoxContainer/MissionsLabel"):
		$MainDisplay/VBoxContainer/MissionsLabel.text = LM.t("hub_missions") + str(completed)

	# Set the Bias Meter visual 
	if bias_meter:
		bias_meter.value = GameManager.bias_meter
		_update_meter_visuals()
	else:
		print("WARNING: bias_meter not found")
	
	# Display mission progress if active
	if has_node("/root/ScenarioManager"):
		var scenario_mgr = get_node("/root/ScenarioManager")
		if scenario_mgr.has_more_scenarios():
			var progress = scenario_mgr.get_progress_string()
			if has_node("MainDisplay/VBoxContainer/ProgressLabel"):
				$MainDisplay/VBoxContainer/ProgressLabel.text = LM.t("hub_mission_progress") + progress
	else:
		print("ERROR: ScenarioManager not found in autoload!")

# Auto-connect any button that should start the mission
func _connect_start_button():
	print("Searching for Start Mission button...")
	
	# Try common button paths
	var button_paths = [
		"StartMissionButton",
		"MainDisplay/StartMissionButton",
		"MainDisplay/VBoxContainer/StartMissionButton",
		"CenterContainer/VBoxContainer/StartMissionButton",
		"Panel/VBoxContainer/StartMissionButton",
		"VBoxContainer/StartMissionButton"
	]
	
	var found_button: Button = null
	
	for path in button_paths:
		if has_node(path):
			var btn = get_node(path)
			if btn is Button:
				print("Found button at: ", path)
				found_button = btn
				break
	
	# If not found by path, search all children recursively
	if not found_button:
		print("Button not found in common paths, searching all children...")
		found_button = _find_button_recursive(self)
	
	if found_button:
		print("Found button: ", found_button.name)
		
		# MAKE BUTTON VISIBLE AND CLICKABLE
		found_button.visible = true
		found_button.disabled = false
		found_button.modulate = Color(1, 1, 1, 1)  # Full opacity
		
		# Set button text using translation
		var LM = get_node("/root/LanguageManager")
		found_button.text = LM.t("btn_start_mission")
		
		print("Button visible: ", found_button.visible)
		print("Button disabled: ", found_button.disabled)
		print("Button text: ", found_button.text)
		print("Button position: ", found_button.position)
		print("Button size: ", found_button.size)
		
		# Disconnect if already connected to avoid duplicates
		if found_button.pressed.is_connected(_on_start_mission_button_pressed):
			found_button.pressed.disconnect(_on_start_mission_button_pressed)
		
		# Connect the signal
		found_button.pressed.connect(_on_start_mission_button_pressed)
		print("✓ Button connected successfully!")
	else:
		print("ERROR: No button found! Please add a Button node to hub.tscn")

# Recursively search for any Button node
func _find_button_recursive(node: Node) -> Button:
	if node is Button:
		# Check if it's likely the start mission button
		if "start" in node.name.to_lower() or "mission" in node.name.to_lower() or "begin" in node.name.to_lower():
			return node
	
	for child in node.get_children():
		var result = _find_button_recursive(child)
		if result:
			return result
	
	return null

func _update_meter_visuals():
	if not bias_meter:
		return
		
	if GameManager.bias_meter > 75:
		bias_meter.modulate = Color.RED
	elif GameManager.bias_meter < 25:
		bias_meter.modulate = Color.CYAN
	else:
		bias_meter.modulate = Color.WHITE

func _on_start_mission_button_pressed():
	print("=== START MISSION BUTTON PRESSED ===")
	
	# Check if ScenarioManager exists
	if not has_node("/root/ScenarioManager"):
		push_error("ScenarioManager not found! Cannot start mission.")
		return
	
	var scenario_mgr = get_node("/root/ScenarioManager")
	
	# Generate a new mission (3 random scenarios from different groups)
	scenario_mgr.generate_mission()
	print("Mission generated successfully")
	
	# Transition to Phase 3: The "Travel" Loading Screen
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")

