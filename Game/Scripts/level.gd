extends Control

# Load the dialogue file
@onready var dialogue_resource = preload("res://Dialogue/main.dialogue")

func _ready():
	# Wait 1 second so the game doesn't start instantly
	await get_tree().create_timer(1.0).timeout
	
	# Show the dialogue balloon
	# "start_engineering" matches the ~ title in your text file
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start_engineering")