extends ProgressBar
class_name AnimatedProgressBar

## Animated progress bar with smooth transitions and visual effects

@export var animation_speed: float = 2.0
@export var glow_enabled: bool = true
@export var color_gradient: bool = true

var target_value: float = 0.0
var current_display_value: float = 0.0

func _ready():
	current_display_value = value
	target_value = value

func _process(delta: float):
	# Smooth animation to target value
	if abs(current_display_value - target_value) > 0.1:
		current_display_value = lerp(current_display_value, target_value, animation_speed * delta)
		value = current_display_value
		_update_color()
	else:
		current_display_value = target_value
		value = current_display_value

func set_value_animated(new_value: float):
	"""Sets the progress bar value with smooth animation"""
	target_value = clamp(new_value, min_value, max_value)

func _update_color():
	"""Updates the fill color based on current value"""
	if not color_gradient:
		return
	
	var fill_style = get_theme_stylebox("fill") as StyleBoxFlat
	if fill_style:
		var progress_percent = value / max_value
		
		# Create color gradient from red -> yellow -> green
		if progress_percent < 0.5:
			# Red to Yellow
			var t = progress_percent * 2.0
			fill_style.bg_color = Color(1.0, t, 0.0)
		else:
			# Yellow to Green
			var t = (progress_percent - 0.5) * 2.0
			fill_style.bg_color = Color(1.0 - t, 1.0, 0.0)

func pulse_effect():
	"""Creates a pulse animation effect"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.2)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
