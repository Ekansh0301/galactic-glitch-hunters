extends Control

# UI References
@onready var name_label = $TopBar/PlayerNameLabel
@onready var rank_label = $TopBar/RankLabel
@onready var score_label = $MainDisplay/VBoxContainer/TotalScoreLabel
@onready var bias_meter = $MainDisplay/VBoxContainer/BiasMeter

func _ready():
	# Populate UI with data from GameManager on entry
	name_label.text = "Cadet: " + GameManager.player_name 
	rank_label.text = "Rank: " + GameManager.current_rank 
	score_label.text = "Total Data Shards: " + str(GameManager.total_score) 
	
	# Set the Bias Meter visual 
	bias_meter.value = GameManager.bias_meter 
	
	# Optional: Change meter color based on bias levels
	_update_meter_visuals()

func _update_meter_visuals():
	if GameManager.bias_meter > 75:
		bias_meter.modulate = Color.RED
	elif GameManager.bias_meter < 25:
		bias_meter.modulate = Color.CYAN
	else:
		bias_meter.modulate = Color.WHITE

var planet_pool = ["EngineeringBay", "Kitchen", "SecurityGate"]

func get_random_planet():
	planet_pool.shuffle()
	var selection = planet_pool.pop_front()
	# Ensure no duplicates by checking against GameManager.visited_planets
	return selection


func _on_start_mission_button_pressed():
	# Transition to Phase 3: The "Travel" Loading Screen
	get_tree().change_scene_to_file("res://Scenes/TravelLoading.tscn")
