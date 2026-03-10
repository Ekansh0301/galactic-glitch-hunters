extends Node

# We keep this just in case, but we won't use it yet
@onready var dialogue_resource = preload("res://Dialogue/main.dialogue")

func _ready():
	# Ensure scene is visible
	self.modulate.a = 1.0
	_setup_animations()
	
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

func _setup_animations():
	"""Sets up button hover effects"""
	if has_node("WarpButton"):
		var button = $WarpButton
		button.mouse_entered.connect(_on_button_hover.bind(button, true))
		button.mouse_exited.connect(_on_button_hover.bind(button, false))
		button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_hover(button: Button, is_hovering: bool):
	"""Handles button hover animation"""
	var target_scale = Vector2(1.05, 1.05) if is_hovering else Vector2.ONE
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", target_scale, 0.15)

func _on_button_pressed(button: Button):
	"""Handles button press animation"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2.ONE, 0.1)

# --- 3. THE WARP BUTTON ---
func _on_warp_button_pressed():
	print("Warp Button Clicked!")
	# Fade out then change scene
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	# This will crash until we make the Loading Screen next!
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
