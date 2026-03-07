extends Control

@onready var name_input = $NameInput
@onready var pass_input = $PasswordInput
@onready var age_input = $Age
@onready var error_label = $ErrorLabel

func _ready():
	print("=== SIGNUP SCREEN READY ===")
	_apply_translations()

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
	# Update button texts
	if has_node("SignupButton"):
		$SignupButton.text = LM.t("btn_signup")
	if has_node("BackButton"):
		$BackButton.text = LM.t("btn_back_login")

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
		get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
	else:
		_show_error(LM.t("err_user_exists"))

func _on_back_button_pressed():
	print("Going back to login")
	get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _show_error(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.RED

func _show_success(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.GREEN
