extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var bias_bar = $ProgressBar # Make sure this matches your node name!
var current_score = 0
var current_bias = 50.0

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
	# Animate score counting up
	var tween = create_tween()
	tween.tween_method(func(val): 
		score_label.text = LM.t("score_label") + str(int(val)),
		current_score, new_score, 0.5)
	current_score = new_score

func update_bias_bar(new_val):
	print("UPDATING BIAS TO: ", new_val)
	# Smooth animate bias bar change
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bias_bar, "value", new_val, 0.4)
	
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