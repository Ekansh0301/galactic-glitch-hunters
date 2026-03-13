extends Node

# ========== LOCAL JSON STORAGE ==========
const SAVE_PATH = "user://accounts.json"

# Accounts dictionary keyed by username.
# Schema per user:
# {
#   "password": String,
#   "age": int,
#   "rank": String,
#   "score": int,
#   "bias_score": int,
#   "scenarios_completed": Array[String],
#   "play_history": Array[Dict],
#   "created_at": String,
#   "last_played": String
# }
var accounts: Dictionary = {}
var current_username: String = ""

# ============================================================
func _ready():
	print("=== AUTHMANAGER (Local Storage) READY ===")
	print("Save path: ", ProjectSettings.globalize_path(SAVE_PATH))
	_load_accounts()

# ============================================================
# AUTHENTICATION
# ============================================================
func authenticate(username: String, password: String) -> bool:
	if accounts.has(username) and accounts[username]["password"] == password:
		current_username = username
		_sync_game_manager(username)
		return true
	return false

func logout():
	current_username = ""
	GameManager.is_logged_in = false
	GameManager.player_name = "Cadet"

# ============================================================
# SIGNUP
# ============================================================
func sign_up(username: String, password: String, age: int) -> bool:
	if accounts.has(username):
		return false  # Username already taken
	accounts[username] = {
		"password": password,
		"age": age,
		"rank": "Cadet",
		"score": 0,
		"best_score": 0,
		"bias_score": 50,
		"scenarios_completed": [],
		"play_history": [],
		"created_at": Time.get_datetime_string_from_system(),
		"last_played": ""
	}
	_save_accounts()
	current_username = username
	_sync_game_manager(username)
	return true

# ============================================================
# RECORD A COMPLETED SCENARIO (call from BattleManager)
# ============================================================
func complete_scenario(scenario_id: String, scenario_title: String,
		player_choice: String = "",
		was_correct: bool = true,
		score_earned: int = 0,
		bias_change: int = 0):
	if current_username == "" or not accounts.has(current_username):
		return
	var user = accounts[current_username]
	if not user["scenarios_completed"].has(scenario_id):
		user["scenarios_completed"].append(scenario_id)
	user["play_history"].append({
		"scenario_id": scenario_id,
		"scenario_title": scenario_title,
		"player_choice": player_choice,
		"was_correct": was_correct,
		"score_earned": score_earned,
		"bias_change": bias_change,
		"played_at": Time.get_datetime_string_from_system()
	})
	if user["play_history"].size() > 100:
		user["play_history"].pop_front()
	user["last_played"] = Time.get_datetime_string_from_system()
	_save_accounts()
	print("AuthManager: Saved scenario '", scenario_id, "' for '", current_username, "'")

# ============================================================
# UPDATE STATS AFTER A FULL MISSION SESSION
# ============================================================
func update_player_stats(new_score: int, new_bias_score: int, new_rank: String):
	if current_username == "" or not accounts.has(current_username):
		return
	var user = accounts[current_username]
	var total_score = max(0, new_score)
	var previous_best = int(user.get("best_score", user.get("score", 0)))
	user["score"] = total_score
	user["best_score"] = max(previous_best, total_score)
	user["bias_score"] = clamp(new_bias_score, 0, 100)
	user["rank"] = new_rank
	user["last_played"] = Time.get_datetime_string_from_system()
	_save_accounts()
	_sync_game_manager(current_username)

func is_guest_session() -> bool:
	return current_username == "" or not accounts.has(current_username)

func reset_current_player_progress() -> bool:
	if is_guest_session():
		return false
	var user = accounts[current_username]
	user["rank"] = "Cadet"
	user["score"] = 0
	user["best_score"] = 0
	user["bias_score"] = 50
	user["scenarios_completed"] = []
	user["play_history"] = []
	user["last_played"] = Time.get_datetime_string_from_system()
	_save_accounts()
	_sync_game_manager(current_username)
	return true

func get_leaderboard_entries(limit: int = 50) -> Array:
	var entries: Array = []
	for username in accounts.keys():
		var user = accounts[username]
		entries.append({
			"username": username,
			"score": int(user.get("score", 0)),
			"rank": user.get("rank", "Cadet"),
			"last_played": user.get("last_played", "")
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary):
		if int(a["score"]) == int(b["score"]):
			return str(a["username"]).nocasecmp_to(str(b["username"])) < 0
		return int(a["score"]) > int(b["score"])
	)
	if limit > 0 and entries.size() > limit:
		entries.resize(limit)
	return entries

# ============================================================
# GETTERS
# ============================================================
func get_player_data(username: String = "") -> Dictionary:
	var uname = username if username != "" else current_username
	return accounts.get(uname, {})

func get_scenarios_completed_count() -> int:
	if current_username != "" and accounts.has(current_username):
		return accounts[current_username]["scenarios_completed"].size()
	return 0

func has_completed_scenario(scenario_id: String) -> bool:
	if current_username != "" and accounts.has(current_username):
		return accounts[current_username]["scenarios_completed"].has(scenario_id)
	return false

# ============================================================
# SYNC GAME MANAGER
# ============================================================
func _sync_game_manager(username: String):
	var user = accounts[username]
	GameManager.player_name  = username
	GameManager.player_age   = user.get("age", 10)
	GameManager.current_rank = user.get("rank", "Cadet")
	GameManager.total_score  = int(user.get("score", 0))
	GameManager.bias_meter   = float(user.get("bias_score", 50))
	GameManager.is_logged_in = true
	print("AuthManager: Synced '", username, "'")

# ============================================================
# FILE I/O
# ============================================================
func _save_accounts():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(accounts, "\t"))
		file.close()
	else:
		push_error("AuthManager: Cannot write to " + SAVE_PATH)

func _load_accounts():
	if not FileAccess.file_exists(SAVE_PATH):
		print("AuthManager: No save file yet.")
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(text) == OK:
			accounts = json.data
			var needs_save = false
			for username in accounts.keys():
				var user = accounts[username]
				if not user.has("best_score"):
					user["best_score"] = int(user.get("score", 0))
					needs_save = true
				if not user.has("rank"):
					user["rank"] = "Cadet"
					needs_save = true
				if not user.has("bias_score"):
					user["bias_score"] = 50
					needs_save = true
				if not user.has("scenarios_completed"):
					user["scenarios_completed"] = []
					needs_save = true
				if not user.has("play_history"):
					user["play_history"] = []
					needs_save = true
				if not user.has("last_played"):
					user["last_played"] = ""
					needs_save = true
				accounts[username] = user
			if needs_save:
				_save_accounts()
			print("AuthManager: Loaded ", accounts.size(), " account(s).")
		else:
			push_error("AuthManager: Corrupt save file!")
