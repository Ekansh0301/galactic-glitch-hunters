extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.finished.connect(_on_video_finished)

func _input(event):
	# Allow players to skip the intro by clicking or pressing any key
	if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
		_on_video_finished()

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/LanguageSelect.tscn")
