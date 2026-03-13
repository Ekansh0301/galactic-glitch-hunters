extends Control

# Add these variables at the very top of the script
var shake_intensity = 3.0 
var original_ship_pos = Vector2.ZERO

@onready var bias_label: Label = null

# 1. The List of Quotes
func _ready():
	print("=== LOADING SCREEN ===")
	# Ensure scene is visible
	self.modulate.a = 1.0
	MusicManager.play_track(MusicManager.TRACK_DIGITAL_SUNSET)
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
	
	# Find or create bias label
	if has_node("BiasLabel"):
		bias_label = $BiasLabel
	
	# Update bias display
	_update_bias_display()
	
	# 3. The Wait Timer (The Loading part)
	await get_tree().create_timer(3.0).timeout
	
	print("Loading complete, moving to PlanetView...")
	
	# Fade out before transitioning
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# 4. Move to next scene
	get_tree().change_scene_to_file("res://Scenes/PlanetView.tscn")

func _update_bias_display():
	"""Updates the bias meter display during loading"""
	if bias_label and has_node("/root/GameManager"):
		var current_bias = GameManager.bias_meter
		bias_label.text = "Bias: " + str(int(current_bias)) + "%"
		
		# Color code based on bias level
		if current_bias > 75:
			bias_label.modulate = Color(1, 0.3, 0.3, 1)  # Red
		elif current_bias < 25:
			bias_label.modulate = Color(0.3, 0.8, 1, 1)  # Cyan
		else:
			bias_label.modulate = Color(0.7, 1, 0.7, 1)  # Green



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