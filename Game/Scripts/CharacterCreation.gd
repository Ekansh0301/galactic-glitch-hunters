extends Control

var current_gender = 1

func _on_male_pressed(): current_gender = 1
func _on_female_pressed(): current_gender = 2
func _on_other_pressed(): current_gender = 3

func _on_confirm_pressed():
	GameManager.save_player_selection(GameManager.player_name, current_gender)
	get_tree().change_scene_to_file("res://Scenes/Level.tscn")
