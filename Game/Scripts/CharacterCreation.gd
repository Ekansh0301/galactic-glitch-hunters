extends Control

func _on_male_pressed(): GameManager.selected_gender_id = 1
func _on_female_pressed(): GameManager.selected_gender_id = 2
func _on_nb_pressed(): GameManager.selected_gender_id = 3

func _on_confirm_pressed():
	get_tree().change_scene_to_file("res://Scenes/Hub.tscn")
