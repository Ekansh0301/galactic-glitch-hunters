extends ProgressBar
class_name BiasMeter

## Enhanced bias meter with color zones, labels, and visual feedback

@export var animation_speed: float = 3.0
@export var show_zones: bool = true
@export var neutral_zone_size: float = 10.0  # Size of neutral zone in the middle

var target_value: float = 50.0
var current_display_value: float = 50.0

@onready var bias_label: Label = null

enum BiasZone {
	EXTREME_LEFT,
	LEFT,
	NEUTRAL,
	RIGHT,
	EXTREME_RIGHT
}

func _ready():
	min_value = 0.0
	max_value = 100.0
	current_display_value = 50.0
	target_value = 50.0
	value = 50.0
	show_percentage = false
	
	# Create bias label if not exists
	if not has_node("BiasLabel"):
		bias_label = Label.new()
		bias_label.name = "BiasLabel"
		bias_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bias_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(bias_label)
		bias_label.position = Vector2(-50, -25)
		bias_label.size = Vector2(size.x + 100, 20)
	else:
		bias_label = $BiasLabel
	
	_update_display()

func _process(delta: float):
	# Smooth animation
	if abs(current_display_value - target_value) > 0.1:
		current_display_value = lerp(current_display_value, target_value, animation_speed * delta)
		value = current_display_value
		_update_display()

func set_bias_animated(new_value: float):
	"""Sets the bias meter value with smooth animation"""
	target_value = clamp(new_value, 0.0, 100.0)

func _update_display():
	"""Updates colors and label based on current bias value"""
	var zone = _get_bias_zone()
	_update_color(zone)
	_update_label(zone)

func _get_bias_zone() -> BiasZone:
	"""Determines which bias zone the current value is in"""
	if value < 20.0:
		return BiasZone.EXTREME_LEFT
	elif value < 50.0 - neutral_zone_size:
		return BiasZone.LEFT
	elif value > 80.0:
		return BiasZone.EXTREME_RIGHT
	elif value > 50.0 + neutral_zone_size:
		return BiasZone.RIGHT
	else:
		return BiasZone.NEUTRAL

func _update_color(zone: BiasZone):
	"""Updates the fill color based on bias zone"""
	var fill_style = get_theme_stylebox("fill") as StyleBoxFlat
	if not fill_style:
		return
	
	match zone:
		BiasZone.EXTREME_LEFT:
			fill_style.bg_color = Color(0.8, 0.1, 0.1, 1)  # Dark Red
			fill_style.border_color = Color(1, 0.2, 0.2, 1)
		BiasZone.LEFT:
			fill_style.bg_color = Color(1, 0.4, 0.4, 1)  # Light Red
			fill_style.border_color = Color(1, 0.6, 0.6, 1)
		BiasZone.NEUTRAL:
			fill_style.bg_color = Color(0.2, 0.8, 0.4, 1)  # Green
			fill_style.border_color = Color(0.4, 1, 0.6, 1)
		BiasZone.RIGHT:
			fill_style.bg_color = Color(0.4, 0.5, 1, 1)  # Light Blue
			fill_style.border_color = Color(0.6, 0.7, 1, 1)
		BiasZone.EXTREME_RIGHT:
			fill_style.bg_color = Color(0.1, 0.2, 0.8, 1)  # Dark Blue
			fill_style.border_color = Color(0.2, 0.4, 1, 1)

func _update_label(zone: BiasZone):
	"""Updates the text label based on bias zone"""
	if not bias_label:
		return
	
	match zone:
		BiasZone.EXTREME_LEFT:
			bias_label.text = "⚠ HEAVILY BIASED LEFT"
			bias_label.modulate = Color(1, 0.3, 0.3, 1)
		BiasZone.LEFT:
			bias_label.text = "← Leaning Left"
			bias_label.modulate = Color(1, 0.6, 0.6, 1)
		BiasZone.NEUTRAL:
			bias_label.text = "✓ BALANCED"
			bias_label.modulate = Color(0.4, 1, 0.6, 1)
		BiasZone.RIGHT:
			bias_label.text = "Leaning Right →"
			bias_label.modulate = Color(0.6, 0.7, 1, 1)
		BiasZone.EXTREME_RIGHT:
			bias_label.text = "⚠ HEAVILY BIASED RIGHT"
			bias_label.modulate = Color(0.3, 0.4, 1, 1)

func pulse_extreme():
	"""Creates a warning pulse when bias is extreme"""
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate:a", 0.7, 0.2)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
