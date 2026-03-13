extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var bias_bar = $ProgressBar # Make sure this matches your node name!
var current_score = 0
var current_bias = 50.0

var _score_tween: Tween
var _score_pulse_tween: Tween
var _bias_tween: Tween

func _ready():
	print("HUD LOADED SUCCESSFULLY")
	
	# 1. Initialize Values
	update_score_text(GameState.score)
	update_bias_bar(GameState.bias_meter)
	
	# 2. Connect Signals
	GameState.score_updated.connect(update_score_text)
	GameState.bias_updated.connect(update_bias_bar)

func update_score_text(new_score):
	var LM = get_node("/root/LanguageManager")
	if score_label == null:
		return

	if is_instance_valid(_score_tween):
		_score_tween.kill()

	if is_instance_valid(_score_pulse_tween):
		_score_pulse_tween.kill()

	score_label.pivot_offset = score_label.size * 0.5
	_score_pulse_tween = create_tween().set_loops()
	_score_pulse_tween.set_trans(Tween.TRANS_SINE)
	_score_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_score_pulse_tween.tween_property(score_label, "scale", Vector2(1.08, 1.08), 0.12)
	_score_pulse_tween.tween_property(score_label, "modulate", Color(1.3, 1.2, 0.9, 1.0), 0.12)
	_score_pulse_tween.tween_property(score_label, "scale", Vector2.ONE, 0.14)
	_score_pulse_tween.tween_property(score_label, "modulate", Color.WHITE, 0.14)

	var duration: float = clampf(absf(float(new_score - current_score)) * 0.012, 0.25, 1.0)
	_score_tween = create_tween()
	_score_tween.tween_method(func(val):
		score_label.text = LM.t("score_label") + str(int(val)),
		current_score,
		new_score,
		duration
	)
	_score_tween.finished.connect(func():
		if is_instance_valid(_score_pulse_tween):
			_score_pulse_tween.kill()
		score_label.scale = Vector2.ONE
		score_label.modulate = Color.WHITE
	)
	current_score = new_score

func update_bias_bar(new_val):
	print("UPDATING BIAS TO: ", new_val)
	# Smooth animate bias bar change
	if bias_bar == null:
		return

	if is_instance_valid(_bias_tween):
		_bias_tween.kill()

	_bias_tween = create_tween()
	_bias_tween.set_ease(Tween.EASE_OUT)
	_bias_tween.set_trans(Tween.TRANS_SINE)
	_bias_tween.tween_property(bias_bar, "value", new_val, 0.5)
	
	# Pulse the bar if bias is getting extreme (< 20 or > 80)
	if new_val < 20 or new_val > 80:
		_pulse_bias_warning()
	
	current_bias = new_val

func _pulse_bias_warning():
	"""Pulses the bias bar to warn player about extreme bias"""
	var original_scale = bias_bar.scale
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(bias_bar, "scale", original_scale * 1.1, 0.2)
	tween.tween_property(bias_bar, "scale", original_scale, 0.2)