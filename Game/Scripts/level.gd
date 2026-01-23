extends Node

@onready var dialogue_resource = preload("res://Dialogue/main.dialogue")

# THIS IS THE MAGIC LINE YOU ARE MISSING:
# It creates the "Dialogue Start Key" box in the Inspector
@export var dialogue_start_key: String = "start_engineering" 

func _ready():
	# 1. Wait 1 second so the game doesn't start instantly
	await get_tree().create_timer(1.0).timeout
	
	# 2. Start the Dialogue using the KEY from the Inspector
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start_key, [self])

# --- THE WARP FUNCTION ---
func load_next_level(next_scene_path: String):
	print("WARPING TO: " + next_scene_path)
	get_tree().change_scene_to_file(next_scene_path)