extends Node

# --- PLAYER INFO ---
# 1 = Male (Female Guide), 2 = Female (Male Guide)
var selected_avatar_id: int = 1
var player_name: String = "Cadet"

# --- GAME PROGRESS ---
var total_score: int = 0
var bias_meter: float = 50.0 

func _ready():
    print("GameManager is active.")