extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.finished.connect(_on_video_finished)

func _input(event):
	# Allow players to skip the credits by pressing space, enter, or Esc
	if false: # Disabled skipping
		_on_video_finished()

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/hub_new.tscn")
