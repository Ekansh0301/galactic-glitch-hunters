extends Control

@onready var name_input = $CenterContainer/MainPanel/NameInput
@onready var pass_input = $CenterContainer/MainPanel/PasswordInput
@onready var age_input = $CenterContainer/MainPanel/Age
@onready var error_label = $CenterContainer/MainPanel/ErrorLabel

func _ready():
	print("=== SIGNUP SCREEN READY ===")
	# Ensure scene is visible
	self.modulate.a = 1.0
	_apply_translations()
	_setup_animations()

func _setup_animations():
	"""Sets up entry animations and button hover effects"""
	# Fade in the main panel
	var panel = $CenterContainer/MainPanel
	panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.6)
	
	# Setup button hover effects
	var buttons = [$CenterContainer/MainPanel/SignupButton, $CenterContainer/MainPanel/BackButton]
	for button in buttons:
		if button:
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
	if name_input:
		name_input.placeholder_text = LM.t("placeholder_signup_name")
	if pass_input:
		pass_input.placeholder_text = LM.t("placeholder_pass")
		pass_input.secret = true
	if age_input:
		age_input.placeholder_text = LM.t("placeholder_age")
	if error_label:
		error_label.text = ""
	# Update button texts with new paths
	if has_node("CenterContainer/MainPanel/SignupButton"):
		$CenterContainer/MainPanel/SignupButton.text = LM.t("btn_signup")
	if has_node("CenterContainer/MainPanel/BackButton"):
		$CenterContainer/MainPanel/BackButton.text = LM.t("btn_back_login")

func _on_signup_button_pressed():
	print("Signup button pressed")
	
	# Validate inputs
	var LM = get_node("/root/LanguageManager")
	if name_input.text.is_empty():
		_show_error(LM.t("err_enter_name2"))
		return
	if pass_input.text.is_empty():
		_show_error(LM.t("err_enter_pass"))
		return
	if age_input.text.is_empty():
		_show_error(LM.t("err_enter_age"))
		return
	var age = age_input.text.to_int()
	if age < 8 or age > 12:
		_show_error(LM.t("err_age_range"))
		return
	if pass_input.text.length() < 4:
		_show_error(LM.t("err_pass_short"))
		return
	
	# Attempt signup
	print("Attempting signup for: ", name_input.text)
	var success = await AuthManager.sign_up(name_input.text, pass_input.text, age)
	
	if success:
		print("Signup successful!")
		_show_success(LM.t("success_account"))
		await get_tree().create_timer(1.0).timeout
		# Fade out before scene change
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		await tween.finished
		get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
	else:
		_show_error(LM.t("err_user_exists"))

func _on_back_button_pressed():
	print("Going back to login")
	# Fade out before scene change
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _show_error(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.RED
		# Shake animation for error
		var original_pos = error_label.position
		var tween = create_tween()
		tween.set_loops(4)
		tween.tween_property(error_label, "position:x", original_pos.x + 5, 0.05)
		tween.tween_property(error_label, "position:x", original_pos.x - 5, 0.05)
		tween.finished.connect(func(): error_label.position = original_pos)

func _show_success(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.GREEN
