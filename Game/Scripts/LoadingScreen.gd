extends Control

# Add these variables at the very top of the script
var shake_intensity = 3.0 
var original_ship_pos = Vector2.ZERO

# 1. The List of Quotes
func _ready():
	print("=== LOADING SCREEN ===")
	var LM = get_node("/root/LanguageManager")

	# Translated quotes
	var educational_quotes = [
		LM.t("loading_tip_1"),
		LM.t("loading_tip_2"),
		LM.t("loading_tip_3"),
		LM.t("loading_tip_4"),
		LM.t("loading_tip_5"),
		LM.t("loading_tip_6"),
	]

	if has_node("SpaceShip"):
		original_ship_pos = $SpaceShip.position

	if has_node("Label"):
		$Label.text = LM.t("loading_title")

	if has_node("QuoteLabel"):
		$QuoteLabel.text = educational_quotes.pick_random()
	
	# 3. The Wait Timer (The Loading part)
	await get_tree().create_timer(3.0).timeout
	
	print("Loading complete, moving to PlanetView...")
	
	# 4. Move to next scene
	get_tree().change_scene_to_file("res://Scenes/PlanetView.tscn")



func _process(_delta):
    # RUMBLE EFFECT
	if has_node("SpaceShip"):
        # Pick a random offset
		print("I can find Spaceship|")
		var x_shake = randf_range(-shake_intensity, shake_intensity)
		var y_shake = randf_range(-shake_intensity, shake_intensity)
        
        # Apply it to the original position
		$SpaceShip.position = original_ship_pos + Vector2(x_shake, y_shake)
	
	else:
		print("ERROR: I cannot find SpaceshipImage! Check the name!")