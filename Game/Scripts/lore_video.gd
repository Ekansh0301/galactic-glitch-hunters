extends Control

@onready var video_player = $VideoStreamPlayer

func _ready():
    # When the lore video finishes, move directly to IntroVideo2
    video_player.finished.connect(_on_video_finished)

func _input(event):
    # Allow players to skip the lore video by clicking or pressing any key
    if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
        _on_video_finished()

func _on_video_finished():
    get_tree().change_scene_to_file("res://Scenes/IntroVideo2.tscn")