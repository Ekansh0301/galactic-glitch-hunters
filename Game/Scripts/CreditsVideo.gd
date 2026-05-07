extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.finished.connect(_on_video_finished)

func _input(event):
	# Allow players to skip the credits by pressing space, enter, or Esc
	if event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_ESCAPE):
		_on_video_finished()

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/hub.tscn")