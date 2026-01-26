extends Control

@onready var name_input = $VBoxContainer/NameInput
@onready var pass_input = $VBoxContainer/PasswordInput
@onready var error_label = $ErrorLabel

func _ready():
	# Set placeholders via code or Inspector
	name_input.placeholder_text = "Enter Username..."
	pass_input.placeholder_text = "Enter Password..."
	pass_input.secret = true # Masks the password

func _on_login_button_pressed():
	if name_input.text.is_empty() or pass_input.text.is_empty():
		_error("Username and Password required!")
		return
	if AuthManager.authenticate(name_input.text, pass_input.text):
		_redirect()
	else:
		_error("Invalid credentials.")

func _on_signup_button_pressed():
	if name_input.text.is_empty() or pass_input.text.is_empty():
		_error("Fill both fields to Sign Up!")
		return
	if AuthManager.sign_up(name_input.text, pass_input.text):
		_redirect()
	else:
		_error("Username already taken!")

func _on_guest_login_button_pressed():
	if name_input.text.is_empty():
		_error("Enter a Guest Name first!")
		return
	GameManager.player_name = name_input.text
	_redirect()

func _error(msg):
	error_label.text = msg
	error_label.modulate = Color.RED

func _redirect():
	get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
