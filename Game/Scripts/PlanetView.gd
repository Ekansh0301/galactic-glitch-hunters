extends Control

func _ready():
	print("=== PLANET VIEW ===")
	
	# --- 1. GET CURRENT SCENARIO ---
	var scenario = ScenarioManager.get_current_scenario()
	
	if scenario:
		print("Showing planet for: ", scenario.title)
		
		# --- 2. LOAD PLANET IMAGE ---
		if has_node("Planet") and scenario.has("planet"):
			var planet_texture = load(scenario.planet)
			if planet_texture:
				$Planet.texture = planet_texture
				print("Loaded planet texture: ", scenario.planet)
			else:
				print("ERROR: Could not load planet texture: ", scenario.planet)
		
		# --- 3. UPDATE THE LABEL WITH SCENARIO TITLE ---
		if has_node("InfoLabel"):
			var LM = get_node("/root/LanguageManager")
			$InfoLabel.text = LM.t("arriving_at") + " " + scenario.title.to_upper()
	else:
		# Fallback if no scenario
		push_warning("No scenario found in PlanetView!")
		if has_node("InfoLabel"):
			var LM = get_node("/root/LanguageManager")
			var random_sector = randi_range(1, 99)
			$InfoLabel.text = LM.t("arriving_at") + " SECTOR " + str(random_sector)
	
	# --- 4. WAIT AND JUMP ---
	print("Waiting 3 seconds before moving to Level2...")
	await get_tree().create_timer(3.0).timeout
	print("Moving to Level2...")
	get_tree().change_scene_to_file("res://Scenes/Level2.tscn")

func _process(delta):
	# OPTIONAL: Makes the planet slowly zoom in
	# If your texture node is named differently, update "TextureRect" below
	if has_node("Planet"):
		$Planet.scale += Vector2(0.05, 0.05) * delta