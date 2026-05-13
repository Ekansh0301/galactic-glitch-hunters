extends Control

@onready var label = $ObjectiveLabel
@onready var timer = $TextTimer

var full_text: String = "Objective: Identify and restore corrupted behavioral logic across affected systems."
var current_index: int = 0

func _ready():
	label.text = ""
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if current_index < full_text.length():
		current_index += 1
		label.text = full_text.substr(0, current_index)
	else:
		timer.stop()