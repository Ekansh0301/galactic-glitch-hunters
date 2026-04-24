extends Node

# ============================================
# SCENARIO MANAGER - The Brain of the Game
# ============================================
# This singleton manages all 15 scenarios across 5 groups
# Ensures no repeats, proper distribution, and gender-adaptive content

# --- SCENARIO DATABASE ---
# Each scenario has: id, group, dialogue_file, background, planet
var scenarios = {
	# GROUP A: Gender Roles & Competence
	"engineering_bay": {
		"id": "engineering_bay",
		"group": "A",
		"title": "The Engineering Bay",
		"dialogue_file": "res://Dialogue/scenario_01_engineering.dialogue",
		"background": "res://Assets/digital-art-dark-cosmic-night-sky.jpg",
		"planet": "res://Assets/Planets/planet00.png"
	},
	"galley_kitchen": {
		"id": "galley_kitchen",
		"group": "A",
		"title": "The Galley Kitchen",
		"dialogue_file": "res://Dialogue/scenario_02_kitchen.dialogue",
		"background": "res://Assets/1781.jpg",
		"planet": "res://Assets/Planets/planet01.png"
	},
	"command_deck": {
		"id": "command_deck",
		"group": "A",
		"title": "The Command Deck",
		"dialogue_file": "res://Dialogue/scenario_03_command.dialogue",
		"background": "res://Assets/1866.jpg",
		"planet": "res://Assets/Planets/planet02.png"
	},
	
	# GROUP B: Respect & Objectification
	"council_chamber": {
		"id": "council_chamber",
		"group": "B",
		"title": "The Council Chamber",
		"dialogue_file": "res://Dialogue/scenario_04_council.dialogue",
		"background": "res://Assets/al_bg1.jpg",
		"planet": "res://Assets/Planets/planet03.png"
	},
	"interview": {
		"id": "interview",
		"group": "B",
		"title": "The Interview",
		"dialogue_file": "res://Dialogue/scenario_05_interview.dialogue",
		"background": "res://Assets/2206_w023_n003_2469b_p1_2469.jpg",
		"planet": "res://Assets/Planets/planet04.png"
	},
	"sports_arena": {
		"id": "sports_arena",
		"group": "B",
		"title": "The Sports Arena",
		"dialogue_file": "res://Dialogue/scenario_06_sports.dialogue",
		"background": "res://Assets/al_bg2.jpg",
		"planet": "res://Assets/Planets/planet05.png"
	},
	
	# GROUP C: Toxic Masculinity
	"battle_arena": {
		"id": "battle_arena",
		"group": "C",
		"title": "The Battle Arena",
		"dialogue_file": "res://Dialogue/scenario_07_emotions.dialogue",
		"background": "res://Assets/al_bg3.jpg",
		"planet": "res://Assets/Planets/planet06.png"
	},
	"medic_bay": {
		"id": "medic_bay",
		"group": "C",
		"title": "The Medic Bay",
		"dialogue_file": "res://Dialogue/scenario_08_medic.dialogue",
		"background": "res://Assets/1781.jpg",
		"planet": "res://Assets/Planets/planet07.png"
	},
	"art_studio": {
		"id": "art_studio",
		"group": "C",
		"title": "The Art Studio",
		"dialogue_file": "res://Dialogue/scenario_09_art.dialogue",
		"background": "res://Assets/1866.jpg",
		"planet": "res://Assets/Planets/planet08.png"
	},
	
	# GROUP D: Inclusion & Identity
	"security_gate": {
		"id": "security_gate",
		"group": "D",
		"title": "The Security Gate",
		"dialogue_file": "res://Dialogue/scenario_10_security.dialogue",
		"background": "res://Assets/al_bg2.jpg",
		"planet": "res://Assets/Planets/planet09.png"
	},
	"classroom": {
		"id": "classroom",
		"group": "D",
		"title": "The Classroom",
		"dialogue_file": "res://Dialogue/scenario_11_pronouns.dialogue",
		"background": "res://Assets/2206_w023_n003_2469b_p1_2469.jpg",
		"planet": "res://Assets/Planets/planet00.png"
	},
	"uniform_depot": {
		"id": "uniform_depot",
		"group": "D",
		"title": "The Uniform Depot",
		"dialogue_file": "res://Dialogue/scenario_12_uniform.dialogue",
		"background": "res://Assets/al_bg3.jpg",
		"planet": "res://Assets/Planets/planet01.png"
	},
	
	# GROUP E: Stereotypes & Assumptions (NEW)
	"toy_store": {
		"id": "toy_store",
		"group": "E",
		"title": "The Toy Store",
		"dialogue_file": "res://Dialogue/scenario_13_toys.dialogue",
		"background": "res://Assets/digital-art-dark-cosmic-night-sky.jpg",
		"planet": "res://Assets/Planets/planet02.png"
	},
	"fitness_center": {
		"id": "fitness_center",
		"group": "E",
		"title": "The Fitness Center",
		"dialogue_file": "res://Dialogue/scenario_14_fitness.dialogue",
		"background": "res://Assets/1781.jpg",
		"planet": "res://Assets/Planets/planet03.png"
	},
	"library": {
		"id": "library",
		"group": "E",
		"title": "The Library",
		"dialogue_file": "res://Dialogue/scenario_15_library.dialogue",
		"background": "res://Assets/1866.jpg",
		"planet": "res://Assets/Planets/planet04.png"
	}
}

# --- CURRENT RUN DATA ---
var current_mission_scenarios = []  # The 3 selected scenarios for this run
var completed_scenarios = []         # Scenarios finished this run
var current_scenario_index = 0       # Which of the 3 we're on

# --- SIGNALS ---
signal mission_complete  # Fired after 3 scenarios

func _ready():
	print("ScenarioManager: Initialized with ", scenarios.size(), " scenarios")

# ============================================
# RANDOMIZER: Pick 3 Scenarios (1 from 3 different groups)
# ============================================
func generate_mission():
	print("=== GENERATING NEW MISSION ===")
	current_mission_scenarios.clear()
	completed_scenarios.clear()
	current_scenario_index = 0
	if has_node("/root/GameState"):
		GameState.reset_run(int(round(GameManager.bias_meter)))
	
	# Step 1: Get all available groups
	var groups = ["A", "B", "C", "D", "E"]
	groups.shuffle()
	
	# Step 2: Pick 3 random groups
	var selected_groups = [groups[0], groups[1], groups[2]]
	print("Selected groups: ", selected_groups)
	
	# Step 3: For each group, pick 1 random scenario
	for group in selected_groups:
		var group_scenarios = []
		for scenario_id in scenarios:
			if scenarios[scenario_id].group == group:
				group_scenarios.append(scenario_id)
		
		# Pick random scenario from this group
		group_scenarios.shuffle()
		current_mission_scenarios.append(group_scenarios[0])
		print("  Group ", group, ": ", group_scenarios[0])
	
	# Step 4: Shuffle the final order
	current_mission_scenarios.shuffle()
	
	print("Mission Generated: ", current_mission_scenarios)
	print("First scenario: ", scenarios[current_mission_scenarios[0]].title)
	return current_mission_scenarios

# ============================================
# GET CURRENT SCENARIO
# ============================================
func get_current_scenario():
	if current_scenario_index < current_mission_scenarios.size():
		var scenario_id = current_mission_scenarios[current_scenario_index]
		print("Getting scenario ", current_scenario_index + 1, "/", current_mission_scenarios.size(), ": ", scenario_id)
		return scenarios[scenario_id]
	print("WARNING: No current scenario available!")
	return null

# ============================================
# MARK SCENARIO COMPLETE & ADVANCE
# ============================================
func complete_current_scenario():
	if current_scenario_index < current_mission_scenarios.size():
		var completed_scenario_id = current_mission_scenarios[current_scenario_index]
		completed_scenarios.append(completed_scenario_id)
		if has_node("/root/AuthManager") and not AuthManager.is_guest_session():
			var completed_scenario = scenarios.get(completed_scenario_id, {})
			AuthManager.complete_scenario(
				completed_scenario_id,
				str(completed_scenario.get("title", completed_scenario_id))
			)
		current_scenario_index += 1
		
		print("Completed: ", completed_scenarios)
		print("Remaining: ", current_mission_scenarios.size() - current_scenario_index)
		
		# Check if mission is done
		if current_scenario_index >= current_mission_scenarios.size():
			GameManager.total_score += GameState.score
			GameManager.bias_meter = float(GameState.bias_meter)
			if has_node("/root/AuthManager") and not AuthManager.is_guest_session():
				AuthManager.update_player_stats(
					GameManager.total_score,
					int(GameManager.bias_meter),
					GameManager.current_rank
				)
			print("MISSION COMPLETE!")
			mission_complete.emit()
			return false  # No more scenarios
		return true  # More scenarios available
	return false

# ============================================
# HELPER: Get Scenario by ID
# ============================================
func get_scenario_by_id(scenario_id: String):
	if scenarios.has(scenario_id):
		return scenarios[scenario_id]
	return null

# ============================================
# PROGRESS TRACKING
# ============================================
func get_progress_string() -> String:
	return str(completed_scenarios.size()) + " / 3"

func has_more_scenarios() -> bool:
	return current_scenario_index < current_mission_scenarios.size()
