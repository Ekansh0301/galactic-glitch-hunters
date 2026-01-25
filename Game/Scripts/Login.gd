extends Control

@onready var name_input = $VBoxContainer/NameInput
@onready var pass_input = $VBoxContainer/PasswordInput
@onready var error_label = $ErrorLabel

func _on_guest_login_button_pressed():
	if name_input.text != "":
		GameManager.player_name = name_input.text
	else:
		GameManager.player_name = "Guest"
	get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")

func _on_language_button_pressed():
	# Simple toggle between EN and ES for example
	var current = TranslationServer.get_locale()
	TranslationServer.set_locale("es" if current == "en" else "en")
func _on_login_button_pressed():
	var username = name_input.text
	var password = pass_input.text
	
	if AuthManager.authenticate(username, password):
		get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
	else:
		error_label.text = "Invalid credentials!"
