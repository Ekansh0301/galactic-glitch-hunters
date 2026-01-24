extends Node

# We keep this just in case, but we won't use it yet
@onready var dialogue_resource = preload("res://Dialogue/main.dialogue")

func _ready():
	# --- 1. HIDE EVERYONE FIRST ---
	# We use 'visible = false' on the Parent Node. 
	# This automatically hides all children (Eyes, Mouth, Hair) too!
	if has_node("Nova_Female"): $Nova_Female.visible = false
	if has_node("Nova_Male"):   $Nova_Male.visible = false
	
	# --- 2. CHECK THE BRAIN ---
	# The Brain (GameManager) remembers if you are a Boy or Girl.
	
	if GameManager.selected_avatar_id == 1: 
		# Player is Male (1) -> Show Female Guide
		if has_node("Nova_Female"): $Nova_Female.visible = true
		print("Logic: Player is Male. Showing FEMALE Nova.")
			
	elif GameManager.selected_avatar_id == 2: 
		# Player is Female (2) -> Show Male Guide
		if has_node("Nova_Male"): $Nova_Male.visible = true
		print("Logic: Player is Female. Showing MALE Nova.")
		
	else:
		# Fallback (Guest) -> Show Female Guide
		if has_node("Nova_Female"): $Nova_Female.visible = true

# --- 3. THE WARP BUTTON ---
func _on_warp_button_pressed():
	print("Warp Button Clicked!")
	# This will crash until we make the Loading Screen next!
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")