extends Control

@onready var name_input = $VBoxContainer/NameInput
@onready var pass_input = $VBoxContainer/PasswordInput
@onready var error_label = $ErrorLabel

func _ready():
	_apply_translations()

func _apply_translations():
	var LM = get_node("/root/LanguageManager")
	# Placeholders
	if name_input:
		name_input.placeholder_text = LM.t("placeholder_name")
	if pass_input:
		pass_input.placeholder_text = LM.t("placeholder_password")
		pass_input.secret = true
	if error_label:
		error_label.text = ""
	# Buttons — exact node names from login.tscn
	if has_node("VBoxContainer/LoginButton"):
		$VBoxContainer/LoginButton.text = LM.t("btn_login")
	if has_node("VBoxContainer/GuestLoginButton"):
		$VBoxContainer/GuestLoginButton.text = LM.t("btn_guest")
	if has_node("VBoxContainer/LanguageButton"):
		$VBoxContainer/LanguageButton.text = LM.t("btn_change_language")
	if has_node("Signup"):
		$Signup.text = LM.t("signup_link")

func _on_login_button_pressed():
	var LM = get_node("/root/LanguageManager")
	if name_input.text.is_empty() or pass_input.text.is_empty():
		_error(LM.t("err_fill_fields"))
		return
	var success = AuthManager.authenticate(name_input.text, pass_input.text)
	if success:
		_redirect()
	else:
		_error(LM.t("err_invalid_creds"))

func _on_guest_login_button_pressed():
	var LM = get_node("/root/LanguageManager")
	if name_input.text.is_empty():
		_error(LM.t("err_enter_name"))
		return
	print("=== GUEST LOGIN ===")
	GameManager.player_name = name_input.text
	GameManager.is_logged_in = true
	_redirect()

func _on_signup_link_pressed():
	get_tree().change_scene_to_file("res://Scenes/signup.tscn")

func _on_signup_pressed():
	_on_signup_link_pressed()

func _error(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.RED

func _redirect():
	get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
