extends Control

@onready var name_input = $VBoxContainer/NameInput

func _on_guest_login_button_pressed():
	if name_input.text != "":
		GameManager.player_name = name_input.text
	get_tree().change_scene_to_file("res://Scenes/CharacterCreation.tscn")

func _on_language_button_pressed():
	# Simple toggle between EN and ES for example
	var current = TranslationServer.get_locale()
	TranslationServer.set_locale("es" if current == "en" else "en")
