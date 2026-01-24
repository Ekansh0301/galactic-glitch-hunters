#extends Node
#
## --- PLAYER INFO ---
## 1 = Male (Female Guide), 2 = Female (Male Guide)
#var selected_avatar_id: int = 1
#var player_name: String = "Cadet"
#
## --- GAME PROGRESS ---
#var total_score: int = 0
#var bias_meter: float = 50.0 
#
#func _ready():
	#print("GameManager is active.")


# res://Scripts/GameManager.gd
extends Node

# --- AUTH INFO ---
var is_logged_in: bool = false
var player_name: String = "Cadet"

# --- CHARACTER INFO ---
# 1 = Male (Female Guide), 2 = Female (Male Guide), 3 = Other
var selected_gender_id: int = 1 
var current_rank: String = "Glitch Magnet"

# --- GAME PROGRESS ---
var total_score: int = 0
var bias_meter: float = 50.0 
var visited_planets: Array = []

func reset_game():
	total_score = 0
	bias_meter = 50.0
	visited_planets.clear()

func save_player_selection(name: String, gender_id: int):
	player_name = name
	selected_gender_id = gender_id
	is_logged_in = true
