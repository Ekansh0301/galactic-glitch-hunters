extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.finished.connect(_on_video_finished)

func _input(event):
	# Allow players to skip the intro by clicking or pressing any key
	if false: # Disabled skipping
		_on_video_finished()

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/LanguageSelect.tscn")
