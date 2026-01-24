extends Control

func _ready():
	# --- 1. GENERATE RANDOM SECTOR ---
	# 'randi_range(1, 99)' picks a random integer between 1 and 99.
	var random_sector = randi_range(1, 99)
	
	# --- 2. UPDATE THE LABEL ---
	# We use 'str()' to turn the number into text so we can combine it.
	if has_node("InfoLabel"):
		$InfoLabel.text = "ARRIVING AT SECTOR " + str(random_sector)
	
	# --- 3. WAIT AND JUMP ---
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Level2.tscn")

func _process(delta):
	# OPTIONAL: Makes the planet slowly zoom in
	# If your texture node is named differently, update "TextureRect" below
	if has_node("Planet"):
		$Planet.scale += Vector2(0.05, 0.05) * delta