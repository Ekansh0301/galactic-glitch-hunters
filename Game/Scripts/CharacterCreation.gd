extends Control

var current_gender = 1

func _ready():
	_apply_translations()

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
	get_tree().change_scene_to_file("res://Scenes/hub.tscn")
