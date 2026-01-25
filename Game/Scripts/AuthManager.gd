extends Node

const SAVE_PATH = "user://player_accounts.json"
var accounts = {
	"admin": {"password": "password123", "rank": "Galactic Master", "score": 999},
	"cadet": {"password": "test", "rank": "Glitch Magnet", "score": 0}
}

func _ready():
	load_accounts()

func load_accounts():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			accounts = json.data

func save_accounts():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(accounts)
	file.store_string(json_string)

func authenticate(username, password) -> bool:
	if accounts.has(username) and accounts[username]["password"] == password:
		# Update GameManager with saved data
		GameManager.player_name = username
		GameManager.current_rank = accounts[username].get("rank", "Glitch Magnet")
		GameManager.total_score = accounts[username].get("score", 0)
		return true
	return false
