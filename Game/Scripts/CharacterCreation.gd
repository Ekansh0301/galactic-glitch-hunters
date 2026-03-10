extends Control

var current_gender = 1

func _ready():
	# Ensure scene is visible
	self.modulate.a = 1.0
	_apply_translations()
	_setup_animations()

func _setup_animations():
	"""Sets up entry animations and button hover effects"""
	# Fade in the title
	if has_node("Background/Choose your Pronouns"):
		var title = $"Background/Choose your Pronouns"
		title.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(title, "modulate:a", 1.0, 0.6)
	
	# Setup button hover effects
	var buttons = ["GenderSelection/Male", "GenderSelection/Female", "GenderSelection/Other", "Confirm"]
	for button_path in buttons:
		if has_node(button_path):
			var button = get_node(button_path)
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

func _apply_translations():
	var LM = get_node("/root/LanguageManager")
	# Exact node names from Character_Creation.tscn
	if has_node("Background/Choose your Pronouns"):
		$"Background/Choose your Pronouns".text = LM.t("char_title")
	if has_node("GenderSelection/Male"):
		$GenderSelection/Male.text = LM.t("btn_male")
	if has_node("GenderSelection/Female"):
		$GenderSelection/Female.text = LM.t("btn_female")
	if has_node("GenderSelection/Other"):
		$GenderSelection/Other.text = LM.t("btn_other")
	if has_node("Confirm"):
		$Confirm.text = LM.t("btn_confirm")

func _on_male_pressed(): current_gender = 1
func _on_female_pressed(): current_gender = 2
func _on_other_pressed(): current_gender = 3

func _on_confirm_pressed():
	print("=== CHARACTER CREATION CONFIRMED ===")
	print("Player name: ", GameManager.player_name)
	print("Selected gender: ", current_gender)
	GameManager.save_player_selection(GameManager.player_name, current_gender)
	print("Going to Hub...")
	# Fade out before scene change
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/hub.tscn")
