extends Control

# ============================================================
# LANGUAGE SELECT — First screen shown on game launch
# Player chooses EN / HI / TE, then navigates to Login
# ============================================================

func _ready():
	print("=== LANGUAGE SELECT SCREEN ===")
	# Labels and buttons are set in the scene; no dynamic text needed here
	# (the buttons themselves are the language names)

func _on_english_button_pressed():
	print("Language selected: English")
	get_node("/root/LanguageManager").set_language("en")
	get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _on_hindi_button_pressed():
	print("Language selected: Hindi")
	get_node("/root/LanguageManager").set_language("hi")
	get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _on_telugu_button_pressed():
	print("Language selected: Telugu")
	get_node("/root/LanguageManager").set_language("te")
	get_tree().change_scene_to_file("res://Scenes/login.tscn")
