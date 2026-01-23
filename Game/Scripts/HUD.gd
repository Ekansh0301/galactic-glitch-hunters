extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var bias_bar = $ProgressBar # Make sure this matches your node name!

func _ready():
	print("HUD LOADED SUCCESSFULLY")
	
	# 1. Initialize Values
	update_score_text(GameState.score)
	update_bias_bar(GameState.bias_meter)
	
	# 2. Connect Signals
	GameState.score_updated.connect(update_score_text)
	GameState.bias_updated.connect(update_bias_bar)

func update_score_text(new_score):
	score_label.text = "Score: " + str(new_score)

func update_bias_bar(new_val):
	print("UPDATING BIAS TO: ", new_val)
	bias_bar.value = new_val