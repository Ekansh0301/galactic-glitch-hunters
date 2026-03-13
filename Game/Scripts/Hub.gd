extends Control

# UI References - Made optional in case nodes don't exist in scene
@onready var name_label = $MainDisplay/VBoxContainer/PlayerNameLabel if has_node("MainDisplay/VBoxContainer/PlayerNameLabel") else null
@onready var rank_label = $MainDisplay/VBoxContainer/RankLabel if has_node("MainDisplay/VBoxContainer/RankLabel") else null
@onready var score_label = $MainDisplay/VBoxContainer/TotalScoreLabel if has_node("MainDisplay/VBoxContainer/TotalScoreLabel") else null
@onready var bias_meter = $BiasContainer/BiasVBox/BiasMeter if has_node("BiasContainer/BiasVBox/BiasMeter") else null
@onready var bias_percent_label = $BiasContainer/BiasVBox/BiasMeter/BiasPercentLabel if has_node("BiasContainer/BiasVBox/BiasMeter/BiasPercentLabel") else null
@onready var settings_button = $TopRightButtons/SettingsButton if has_node("TopRightButtons/SettingsButton") else null
@onready var leaderboard_button = $TopRightButtons/LeaderboardButton if has_node("TopRightButtons/LeaderboardButton") else null

const CLIENT_SETTINGS_PATH := "user://client_settings.json"
const CLIENT_DEFAULTS := {
	"language": "en",
	"master_volume_db": 0.0,
	"fullscreen": false
}

var client_settings: Dictionary = CLIENT_DEFAULTS.duplicate(true)

var _settings_popup: AcceptDialog
var _leaderboard_popup: AcceptDialog
var _leaderboard_text: RichTextLabel
var _settings_language_label: Label
var _settings_volume_label: Label
var _settings_status_label: Label
var _music_credits_title: Label
var _music_credits_text: RichTextLabel
var _language_selector: OptionButton
var _volume_slider: HSlider
var _volume_value_label: Label
var _fullscreen_toggle: CheckBox
var _settings_cancel_button: Button
var _settings_reset_button: Button
var _settings_logout_button: Button

func _ready():
	print("=== HUB LOADED ===")
	print("Player Name: ", GameManager.player_name)
	print("Current Rank: ", GameManager.current_rank)
	print("Total Score: ", GameManager.total_score)
	MusicManager.play_track(MusicManager.TRACK_DIGITAL_SUNSET)

	_load_client_settings()
	_apply_client_settings()
	
	# Ensure the hub itself is visible (in case previous scene faded out)
	self.modulate.a = 1.0
	
	# Setup animations first
	_setup_animations()
	
	# AUTO-CONNECT START MISSION BUTTON
	_connect_start_button()
	_connect_top_buttons()
	
	if not LanguageManager.language_changed.is_connected(_on_language_changed):
		LanguageManager.language_changed.connect(_on_language_changed)

	_refresh_hub_ui()
	_ensure_settings_popup()
	_ensure_leaderboard_popup()
	_refresh_popup_labels()

func _exit_tree():
	if LanguageManager and LanguageManager.language_changed.is_connected(_on_language_changed):
		LanguageManager.language_changed.disconnect(_on_language_changed)

func _on_language_changed(_lang_code: String):
	_refresh_hub_ui()
	_refresh_popup_labels()
	

func _refresh_hub_ui():
	var LM = get_node("/root/LanguageManager")

	# Populate UI with data from GameManager
	if name_label:
		name_label.text = LM.t("hub_cadet") + GameManager.player_name
	else:
		print("WARNING: name_label not found")
		
	if rank_label:
		rank_label.text = LM.t("hub_rank") + GameManager.current_rank
	else:
		print("WARNING: rank_label not found")
		
	if score_label:
		score_label.text = LM.t("hub_score") + str(GameManager.total_score)
	else:
		print("WARNING: score_label not found")
	
	# Show scenarios completed count
	var completed = AuthManager.get_scenarios_completed_count()
	if has_node("MainDisplay/VBoxContainer/MissionsLabel"):
		$MainDisplay/VBoxContainer/MissionsLabel.text = LM.t("hub_missions") + str(completed)

	# Set the Bias Meter visual 
	if bias_meter:
		bias_meter.value = GameManager.bias_meter
		_update_meter_visuals()
		# Update percentage label
		if bias_percent_label:
			bias_percent_label.text = str(int(GameManager.bias_meter)) + "%"
	else:
		print("WARNING: bias_meter not found")
	
	# Display mission progress if active
	if has_node("/root/ScenarioManager"):
		var scenario_mgr = get_node("/root/ScenarioManager")
		if scenario_mgr.has_more_scenarios():
			var progress = scenario_mgr.get_progress_string()
			if has_node("MainDisplay/VBoxContainer/ProgressLabel"):
				$MainDisplay/VBoxContainer/ProgressLabel.text = LM.t("hub_mission_progress") + progress
	else:
		print("ERROR: ScenarioManager not found in autoload!")

	if has_node("BiasContainer/BiasVBox/BiasLabel"):
		$BiasContainer/BiasVBox/BiasLabel.text = LM.t("bias_label")

	if settings_button:
		settings_button.text = LM.t("btn_settings")
	if leaderboard_button:
		leaderboard_button.text = LM.t("btn_leaderboard")

func _setup_animations():
	"""Sets up entry animations and button hover effects"""
	# Fade in the main display
	if has_node("MainDisplay"):
		var main_display = $MainDisplay
		main_display.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(main_display, "modulate:a", 1.0, 0.8)
	
	# Fade in the bias container
	if has_node("BiasContainer"):
		var bias_container = $BiasContainer
		bias_container.modulate.a = 0.0
		var tween2 = create_tween()
		tween2.tween_property(bias_container, "modulate:a", 1.0, 0.8)
	
	# Setup button hover effect for start mission button
	var hover_buttons: Array[Button] = []
	if has_node("MainDisplay/VBoxContainer/StartMissionButton"):
		hover_buttons.append($MainDisplay/VBoxContainer/StartMissionButton)
	if settings_button:
		hover_buttons.append(settings_button)
	if leaderboard_button:
		hover_buttons.append(leaderboard_button)

	for button in hover_buttons:
		if not button.mouse_entered.is_connected(_on_button_hover.bind(button, true)):
			button.mouse_entered.connect(_on_button_hover.bind(button, true))
		if not button.mouse_exited.is_connected(_on_button_hover.bind(button, false)):
			button.mouse_exited.connect(_on_button_hover.bind(button, false))
		if not button.pressed.is_connected(_on_button_pressed.bind(button)):
			button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_hover(button: Button, is_hovering: bool):
	"""Handles button hover animation"""
	var target_scale = Vector2(1.05, 1.05) if is_hovering else Vector2.ONE
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", target_scale, 0.15)

func _on_button_pressed(button: Button):
	"""Handles button press animation"""
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2.ONE, 0.1)

func _connect_top_buttons():
	if settings_button and not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
	if leaderboard_button and not leaderboard_button.pressed.is_connected(_on_leaderboard_button_pressed):
		leaderboard_button.pressed.connect(_on_leaderboard_button_pressed)

func _on_settings_button_pressed():
	_ensure_settings_popup()
	_sync_settings_controls()
	_settings_popup.popup_centered(Vector2i(540, 430))

func _on_leaderboard_button_pressed():
	if AuthManager.is_guest_session():
		_show_info(LanguageManager.t("leaderboard_signin_prompt"))
		return

	_ensure_leaderboard_popup()
	_refresh_leaderboard_text()
	_leaderboard_popup.popup_centered(Vector2i(560, 460))

func _ensure_settings_popup():
	if _settings_popup:
		return

	_settings_popup = AcceptDialog.new()
	_settings_popup.title = "Settings"
	_settings_popup.dialog_autowrap = true
	_settings_popup.confirmed.connect(_on_settings_confirmed)
	_settings_popup.custom_action.connect(_on_settings_custom_action)
	_settings_popup.canceled.connect(_clear_settings_status)
	add_child(_settings_popup)

	var root = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.custom_minimum_size = Vector2(500, 300)
	root.add_theme_constant_override("separation", 8)
	_settings_popup.add_child(root)

	_settings_language_label = Label.new()
	root.add_child(_settings_language_label)

	_language_selector = OptionButton.new()
	_language_selector.item_selected.connect(_on_settings_language_selected)
	root.add_child(_language_selector)

	_settings_volume_label = Label.new()
	root.add_child(_settings_volume_label)

	var volume_row = HBoxContainer.new()
	volume_row.add_theme_constant_override("separation", 8)
	root.add_child(volume_row)

	_volume_slider = HSlider.new()
	_volume_slider.min_value = -40.0
	_volume_slider.max_value = 0.0
	_volume_slider.step = 1.0
	_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_volume_slider.value_changed.connect(_on_volume_value_changed)
	volume_row.add_child(_volume_slider)

	_volume_value_label = Label.new()
	_volume_value_label.custom_minimum_size = Vector2(58, 0)
	volume_row.add_child(_volume_value_label)

	_fullscreen_toggle = CheckBox.new()
	_fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	root.add_child(_fullscreen_toggle)

	_settings_status_label = Label.new()
	_settings_status_label.modulate = Color(0.9, 1.0, 0.9, 1.0)
	_settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_settings_status_label)

	_music_credits_title = Label.new()
	root.add_child(_music_credits_title)

	_music_credits_text = RichTextLabel.new()
	_music_credits_text.custom_minimum_size = Vector2(0, 96)
	_music_credits_text.fit_content = false
	_music_credits_text.bbcode_enabled = false
	_music_credits_text.scroll_active = true
	_music_credits_text.selection_enabled = true
	root.add_child(_music_credits_text)

	_settings_reset_button = _settings_popup.add_button("", false, "reset_progress")
	_settings_logout_button = _settings_popup.add_button("", false, "logout")
	_settings_cancel_button = _settings_popup.add_cancel_button("")

func _ensure_leaderboard_popup():
	if _leaderboard_popup:
		return

	_leaderboard_popup = AcceptDialog.new()
	_leaderboard_popup.title = "Leaderboard"
	add_child(_leaderboard_popup)

	_leaderboard_text = RichTextLabel.new()
	_leaderboard_text.custom_minimum_size = Vector2(530, 360)
	_leaderboard_text.bbcode_enabled = true
	_leaderboard_text.fit_content = false
	_leaderboard_popup.add_child(_leaderboard_text)

func _refresh_popup_labels():
	if _settings_popup:
		var LM = LanguageManager
		_settings_popup.title = LM.t("settings_title")
		_settings_language_label.text = LM.t("settings_language")
		_settings_volume_label.text = LM.t("settings_master_volume")
		_fullscreen_toggle.text = LM.t("settings_fullscreen")
		_settings_popup.get_ok_button().text = LM.t("btn_save")
		if _settings_cancel_button:
			_settings_cancel_button.text = LM.t("btn_close")
		if _settings_reset_button:
			_settings_reset_button.text = LM.t("settings_reset_progress")
		if _settings_logout_button:
			_settings_logout_button.text = LM.t("settings_logout")
		if _music_credits_title:
			_music_credits_title.text = LM.t("settings_music_credits")
		if _music_credits_text:
			_music_credits_text.text = MusicManager.get_music_credits_text()
		_refresh_language_selector_items()

	if _leaderboard_popup:
		_leaderboard_popup.title = LanguageManager.t("leaderboard_title")
		_leaderboard_popup.get_ok_button().text = LanguageManager.t("btn_close")

func _refresh_language_selector_items():
	if not _language_selector:
		return
	_language_selector.clear()
	_language_selector.add_item(LanguageManager.t("btn_english"))
	_language_selector.set_item_metadata(0, "en")
	_language_selector.add_item(LanguageManager.t("btn_hindi"))
	_language_selector.set_item_metadata(1, "hi")
	_language_selector.add_item(LanguageManager.t("btn_telugu"))
	_language_selector.set_item_metadata(2, "te")
	_sync_selected_language()

func _sync_selected_language():
	if not _language_selector:
		return
	var current_lang = LanguageManager.get_language()
	for i in _language_selector.item_count:
		if str(_language_selector.get_item_metadata(i)) == current_lang:
			_language_selector.select(i)
			return

func _sync_settings_controls():
	_refresh_popup_labels()
	if _volume_slider:
		_volume_slider.value = float(client_settings.get("master_volume_db", 0.0))
		_update_volume_label(float(_volume_slider.value))
	if _fullscreen_toggle:
		_fullscreen_toggle.button_pressed = bool(client_settings.get("fullscreen", false))
	_clear_settings_status()

func _on_settings_language_selected(index: int):
	var lang_code = str(_language_selector.get_item_metadata(index))
	client_settings["language"] = lang_code
	LanguageManager.set_language(lang_code)
	_save_client_settings()

func _on_volume_value_changed(value: float):
	client_settings["master_volume_db"] = value
	AudioServer.set_bus_volume_db(0, value)
	_update_volume_label(value)

func _on_fullscreen_toggled(enabled: bool):
	client_settings["fullscreen"] = enabled
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_settings_confirmed():
	_save_client_settings()
	_set_settings_status(LanguageManager.t("settings_saved"))

func _on_settings_custom_action(action: StringName):
	if action == "reset_progress":
		if AuthManager.reset_current_player_progress():
			_refresh_hub_ui()
			_set_settings_status(LanguageManager.t("settings_reset_done"))
		else:
			_set_settings_status(LanguageManager.t("settings_reset_guest"), true)
	elif action == "logout":
		AuthManager.logout()
		get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _update_volume_label(db_value: float):
	if not _volume_value_label:
		return
	var percent = int(round(clamp(db_to_linear(db_value), 0.0, 1.0) * 100.0))
	_volume_value_label.text = str(percent) + "%"

func _set_settings_status(message: String, is_error: bool = false):
	if not _settings_status_label:
		return
	_settings_status_label.text = message
	_settings_status_label.modulate = Color(1.0, 0.6, 0.6, 1.0) if is_error else Color(0.9, 1.0, 0.9, 1.0)

func _clear_settings_status():
	if _settings_status_label:
		_settings_status_label.text = ""

func _show_info(message: String):
	var popup = AcceptDialog.new()
	popup.dialog_text = message
	popup.title = LanguageManager.t("info")
	popup.get_ok_button().text = LanguageManager.t("btn_close")
	add_child(popup)
	popup.popup_centered(Vector2i(460, 180))
	popup.confirmed.connect(func(): popup.queue_free())
	popup.canceled.connect(func(): popup.queue_free())

func _refresh_leaderboard_text():
	if not _leaderboard_text:
		return
	var entries = AuthManager.get_leaderboard_entries(100)
	var LM = LanguageManager
	if entries.is_empty():
		_leaderboard_text.text = LM.t("leaderboard_empty")
		return

	var lines: Array[String] = []
	lines.append("[b]%s[/b]\n" % LM.t("leaderboard_header"))
	var place = 1
	for entry in entries:
		var line = "%d. %s  -  %d" % [place, entry["username"], int(entry["score"])]
		if String(entry["username"]) == AuthManager.current_username:
			line = "[color=#FFE082]%s[/color]" % line
		lines.append(line)
		place += 1
	_leaderboard_text.text = "\n".join(lines)

func _load_client_settings():
	client_settings = CLIENT_DEFAULTS.duplicate(true)
	if not FileAccess.file_exists(CLIENT_SETTINGS_PATH):
		return
	var file = FileAccess.open(CLIENT_SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(content) != OK or not (json.data is Dictionary):
		return
	for key in CLIENT_DEFAULTS.keys():
		if json.data.has(key):
			client_settings[key] = json.data[key]

func _save_client_settings():
	var file = FileAccess.open(CLIENT_SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(client_settings, "\t"))
		file.close()

func _apply_client_settings():
	var lang_code = str(client_settings.get("language", "en"))
	LanguageManager.set_language(lang_code)

	var db_value = float(client_settings.get("master_volume_db", 0.0))
	AudioServer.set_bus_volume_db(0, db_value)

	var fullscreen = bool(client_settings.get("fullscreen", false))
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Auto-connect any button that should start the mission
func _connect_start_button():
	print("Searching for Start Mission button...")
	
	# Try common button paths
	var button_paths = [
		"StartMissionButton",
		"MainDisplay/StartMissionButton",
		"MainDisplay/VBoxContainer/StartMissionButton",
		"CenterContainer/VBoxContainer/StartMissionButton",
		"Panel/VBoxContainer/StartMissionButton",
		"VBoxContainer/StartMissionButton"
	]
	
	var found_button: Button = null
	
	for path in button_paths:
		if has_node(path):
			var btn = get_node(path)
			if btn is Button:
				print("Found button at: ", path)
				found_button = btn
				break
	
	# If not found by path, search all children recursively
	if not found_button:
		print("Button not found in common paths, searching all children...")
		found_button = _find_button_recursive(self)
	
	if found_button:
		print("Found button: ", found_button.name)
		
		# MAKE BUTTON VISIBLE AND CLICKABLE
		found_button.visible = true
		found_button.disabled = false
		found_button.modulate = Color(1, 1, 1, 1)  # Full opacity
		
		# Set button text using translation
		var LM = get_node("/root/LanguageManager")
		found_button.text = LM.t("btn_start_mission")
		
		print("Button visible: ", found_button.visible)
		print("Button disabled: ", found_button.disabled)
		print("Button text: ", found_button.text)
		print("Button position: ", found_button.position)
		print("Button size: ", found_button.size)
		
		# Disconnect if already connected to avoid duplicates
		if found_button.pressed.is_connected(_on_start_mission_button_pressed):
			found_button.pressed.disconnect(_on_start_mission_button_pressed)
		
		# Connect the signal
		found_button.pressed.connect(_on_start_mission_button_pressed)
		print("✓ Button connected successfully!")
	else:
		print("ERROR: No button found! Please add a Button node to hub.tscn")

# Recursively search for any Button node
func _find_button_recursive(node: Node) -> Button:
	if node is Button:
		# Check if it's likely the start mission button
		if "start" in node.name.to_lower() or "mission" in node.name.to_lower() or "begin" in node.name.to_lower():
			return node
	
	for child in node.get_children():
		var result = _find_button_recursive(child)
		if result:
			return result
	
	return null

func _update_meter_visuals():
	if not bias_meter:
		return
	
	# Update the percentage label
	if bias_percent_label:
		bias_percent_label.text = str(int(GameManager.bias_meter)) + "%"
		
	if GameManager.bias_meter > 75:
		bias_meter.modulate = Color.RED
		if bias_percent_label:
			bias_percent_label.modulate = Color(1, 0.8, 0.8, 1)
	elif GameManager.bias_meter < 25:
		bias_meter.modulate = Color.CYAN
		if bias_percent_label:
			bias_percent_label.modulate = Color(0.8, 0.9, 1, 1)
	else:
		bias_meter.modulate = Color.WHITE
		if bias_percent_label:
			bias_percent_label.modulate = Color.WHITE

func _on_start_mission_button_pressed():
	print("=== START MISSION BUTTON PRESSED ===")
	
	# Check if ScenarioManager exists
	if not has_node("/root/ScenarioManager"):
		push_error("ScenarioManager not found! Cannot start mission.")
		return
	
	var scenario_mgr = get_node("/root/ScenarioManager")
	
	# Generate a new mission (3 random scenarios from different groups)
	scenario_mgr.generate_mission()
	print("Mission generated successfully")
	
	# Fade out before transitioning
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# Transition to Phase 3: The "Travel" Loading Screen
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
