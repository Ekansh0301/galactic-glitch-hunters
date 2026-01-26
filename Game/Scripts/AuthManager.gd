extends Node

const SAVE_PATH = "user://accounts.json"
var accounts = {
	"admin": {"password": "password123", "rank": "Galactic Master", "score": 999}
}

func _ready():
	print("Account file location: ", ProjectSettings.globalize_path(SAVE_PATH))
	load_accounts()

func authenticate(username, password) -> bool:
	if accounts.has(username) and accounts[username]["password"] == password:
		_sync_game_manager(username)
		return true
	return false

func sign_up(username, password) -> bool:
	if accounts.has(username): return false # User exists
	accounts[username] = {"password": password, "rank": "Cadet", "score": 0}
	save_accounts()
	_sync_game_manager(username)
	return true

func _sync_game_manager(username):
	GameManager.player_name = username
	GameManager.current_rank = accounts[username]["rank"]
	GameManager.total_score = accounts[username]["score"]

func save_accounts():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(accounts)) # Persistent JSON storage

func load_accounts():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			accounts = json.data
