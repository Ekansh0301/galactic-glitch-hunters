extends Node

# --- VARIABLES (The Game's Long-Term Memory) ---
var score: int = 0
var bias_meter: int = 50 # 50 is Neutral. 0 = Pure Logic, 100 = Pure Emotion.

# --- SIGNALS (To shout updates to the HUD) ---
signal score_updated(new_score)
signal bias_updated(new_bias)

# --- FUNCTIONS ---

# Call this when the player makes a "Smart" choice
func add_score(amount: int):
	score += amount
	print("MEMORY: Score added. Current: ", score)
	score_updated.emit(score) # Tell the HUD to update

# Call this to shift the Logic/Emotion balance
func shift_bias(amount: int):
	bias_meter += amount
	# Clamp ensures it stays between 0 and 100
	bias_meter = clamp(bias_meter, 0, 100) 
	print("MEMORY: Bias shifted. Current: ", bias_meter)
	bias_updated.emit(bias_meter)

func reset_run(start_bias: int = 50):
	score = 0
	bias_meter = clamp(start_bias, 0, 100)
	print("MEMORY: Run reset. Score: ", score, " Bias: ", bias_meter)
	score_updated.emit(score)
	bias_updated.emit(bias_meter)
