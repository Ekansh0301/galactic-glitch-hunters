extends Control

# Add these variables at the very top of the script
var shake_intensity = 3.0 
var original_ship_pos = Vector2.ZERO

# 1. The List of Quotes
var educational_quotes = [
	"Did you know? Mars has the largest volcano in the solar system.",
	"Bias is when we let feelings cloud our judgment.",
	"The core of a star is millions of degrees hot!",
	"Always check your sources before believing a rumor.",
	"Robots follow logic, but humans follow emotions.",
	"Light takes 8 minutes to travel from the Sun to Earth."
]

func _ready():
	# 2. Pick a Random Quote
	# 'pick_random()' is a built-in Godot function that does exactly what you want.
	if has_node("SpaceShip"):
		original_ship_pos = $SpaceShip.position

	if has_node("QuoteLabel"):
		$QuoteLabel.text = educational_quotes.pick_random()
	
	# 3. The Wait Timer (The Loading part)
	await get_tree().create_timer(3.0).timeout
	
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