extends Node

# --- AUTH INFO ---
var is_logged_in: bool = false
var player_name: String = "Cadet"

# --- CHARACTER INFO ---
# 1. THE OLD VARIABLE (Keeps Level 1 & Level 2 working)
var selected_avatar_id: int = 1 

# 2. THE NEW VARIABLE (From your Git Pull)
var selected_gender_id: int = 1   

# 3. NOVA'S GENDER (Needed for Level 2 Cutscene)
var selected_nova: String = "female"

var current_rank: String = "Glitch Magnet"

# --- GAME PROGRESS ---
var total_score: int = 0
var bias_meter: float = 50.0 
var visited_planets: Array = []

func _ready():
	print("GameManager is active.")

func reset_game():
	total_score = 0
	bias_meter = 50.0
	visited_planets.clear()

# This function is called by the Character Creation screen
# This function is called by the Character Creation screen
# We changed 'name' to 'p_name' to fix the shadowing warning
func save_player_selection(p_name: String, gender_id: int):
	player_name = p_name
	
	# UPDATE BOTH VARIABLES (Keeps everything in sync)
	selected_gender_id = gender_id
	selected_avatar_id = gender_id 
	
	# LOGIC: Set Nova opposite to Player
	if gender_id == 1:
		selected_nova = "female"
	elif gender_id == 2:
		selected_nova = "male"
	else:
		selected_nova = "female"
		
	is_logged_in = true