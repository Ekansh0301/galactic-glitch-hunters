extends Button

var _settings_popup: AcceptDialog
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
		# Add basic opaque style box to self
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.05, 0.05, 1.0) # Dark opaque gray
		style.border_width_bottom = 2
		style.border_width_top = 2
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_color = Color(0.4, 0.4, 0.4, 1.0)
		self.add_theme_stylebox_override("normal", style)
		self.add_theme_stylebox_override("hover", style)
		self.add_theme_stylebox_override("pressed", style)
		
		# Keep it bottom right
		self.anchors_preset = Control.PRESET_BOTTOM_RIGHT
		
		self.pressed.connect(_on_pressed)
		
		if get_tree().root.has_node("LanguageManager"):
				var LM = get_node("/root/LanguageManager")
				if not LM.language_changed.is_connected(_on_language_changed):
						LM.language_changed.connect(_on_language_changed)

func _on_language_changed(_lang_code: String):
		var LM = get_node("/root/LanguageManager")
		self.text = LM.t("btn_settings") if LM.has_method("t") else "Settings"
		
		if _settings_popup:
				_settings_popup.title = LM.t("settings_title")
				_settings_language_label.text = LM.t("settings_language")
				_settings_volume_label.text = LM.t("settings_master_volume")
				_fullscreen_toggle.text = LM.t("settings_fullscreen")
				_settings_popup.get_ok_button().text = LM.t("btn_save")
				if _settings_cancel_button: _settings_cancel_button.text = LM.t("btn_close")
				if _settings_reset_button: _settings_reset_button.text = LM.t("settings_reset_progress")
				if _settings_logout_button: _settings_logout_button.text = LM.t("settings_logout")
				_music_credits_title.text = LM.t("settings_music_credits")

func _on_pressed():
		if not _settings_popup:
				_ensure_settings_popup()
		_sync_settings_controls()
		_settings_popup.popup_centered(Vector2i(540, 430))

func _ensure_settings_popup():
		_settings_popup = AcceptDialog.new()
		_settings_popup.title = "Settings"
		_settings_popup.dialog_autowrap = true
		
		# _on_settings_confirmed -> saves settings
		_settings_popup.confirmed.connect(_on_settings_confirmed)
		_settings_popup.custom_action.connect(_on_settings_custom_action)
		_settings_popup.canceled.connect(_clear_settings_status)
		
		add_child(_settings_popup)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		_settings_popup.add_child(margin)
		
		var root = VBoxContainer.new()
		root.add_theme_constant_override("separation", 15)
		margin.add_child(root)
		
		# UI Setup 
		_settings_language_label = Label.new()
		root.add_child(_settings_language_label)
		_language_selector = OptionButton.new()
		_language_selector.add_item("English", 0)
		_language_selector.set_item_metadata(0, "en")
		_language_selector.add_item("हिंदी", 1)
		_language_selector.set_item_metadata(1, "hi")
		_language_selector.add_item("తెలుగు", 2)
		_language_selector.set_item_metadata(2, "te")
		root.add_child(_language_selector)
		_language_selector.item_selected.connect(_on_settings_language_selected)
		
		_settings_volume_label = Label.new()
		root.add_child(_settings_volume_label)
		var vol_hbox = HBoxContainer.new()
		root.add_child(vol_hbox)
		_volume_slider = HSlider.new()
		_volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_volume_slider.min_value = -30.0
		_volume_slider.max_value = 10.0
		_volume_slider.step = 1.0
		_volume_slider.value_changed.connect(_on_settings_volume_changed)
		vol_hbox.add_child(_volume_slider)
		_volume_value_label = Label.new()
		_volume_value_label.custom_minimum_size.x = 40
		vol_hbox.add_child(_volume_value_label)
		
		_fullscreen_toggle = CheckBox.new()
		_fullscreen_toggle.toggled.connect(_on_settings_fullscreen_toggled)
		root.add_child(_fullscreen_toggle)
		
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 10
		root.add_child(spacer)
		
		_settings_status_label = Label.new()
		_settings_status_label.modulate = Color(0.9, 1.0, 0.9, 1.0)
		_settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		root.add_child(_settings_status_label)
		
		_music_credits_title = Label.new()
		_music_credits_title.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		root.add_child(_music_credits_title)
		
		_music_credits_text = RichTextLabel.new()
		_music_credits_text.bbcode_enabled = true
		var credits = "Signal to Noise - Scott Buckley (CC-BY 4.0)\nDigital Sunset - Music by Karl Casey @ White Bat Audio\nVolatile Reaction - Kevin MacLeod (CC-BY 4.0)"
		_music_credits_text.text = "[font_size=12]%s[/font_size]" % credits
		_music_credits_text.custom_minimum_size = Vector2(0, 80)
		root.add_child(_music_credits_text)
		
		_settings_reset_button = _settings_popup.add_button("", false, "reset_progress")
		_settings_logout_button = _settings_popup.add_button("", false, "logout")
		_settings_cancel_button = _settings_popup.add_cancel_button("")
		
		_on_language_changed("") # Init translations

func _sync_settings_controls():
		var hub_or_gm = get_node_or_null("/root/GameManager")
		# Load from file to ensure they are synchronized independently
		var client_settings = { "language": "en", "master_volume_db": 0.0, "fullscreen": false }
		if FileAccess.file_exists("user://client_settings.json"):
				var file = FileAccess.open("user://client_settings.json", FileAccess.READ)
				if file:
						var json = JSON.new()
						if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
								for key in json.data: client_settings[key] = json.data[key]
		
		var lang_code = client_settings.get("language", "en")
		for i in range(_language_selector.get_item_count()):
				if _language_selector.get_item_metadata(i) == lang_code:
						_language_selector.select(i)
						break
						
		_volume_slider.value = float(client_settings.get("master_volume_db", 0.0))
		AudioServer.set_bus_volume_db(0, _volume_slider.value)
		_fullscreen_toggle.button_pressed = bool(client_settings.get("fullscreen", false))
		_clear_settings_status()

func _on_settings_language_selected(index: int):
		var lang_code = _language_selector.get_item_metadata(index)
		if get_tree().root.has_node("LanguageManager"):
				get_node("/root/LanguageManager").set_language(lang_code)

func _on_settings_volume_changed(value: float):
		_volume_value_label.text = "%d dB" % value
		AudioServer.set_bus_volume_db(0, value)

func _on_settings_fullscreen_toggled(enabled: bool):
		if enabled:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_settings_confirmed():
		var settings = {
				"language": _language_selector.get_item_metadata(_language_selector.selected),
				"master_volume_db": _volume_slider.value,
				"fullscreen": _fullscreen_toggle.button_pressed
		}
		var file = FileAccess.open("user://client_settings.json", FileAccess.WRITE)
		if file:
				file.store_string(JSON.stringify(settings, "\t"))
		
		if get_tree().root.has_node("LanguageManager"):
				_set_settings_status(get_node("/root/LanguageManager").t("settings_saved"))

func _on_settings_custom_action(action: StringName):
		if action == "reset_progress":
				if get_node_or_null("/root/AuthManager") and get_node("/root/AuthManager").is_guest():
						if get_tree().root.has_node("LanguageManager"):
								_set_settings_status(get_node("/root/LanguageManager").t("settings_reset_guest"), true)
				else:
						if get_tree().root.has_node("AuthManager"): get_node("/root/AuthManager").reset_progress()
						if get_tree().root.has_node("GameManager"): get_node("/root/GameManager").reset_game()
						if get_tree().root.has_node("LanguageManager"):
								_set_settings_status(get_node("/root/LanguageManager").t("settings_reset_done"))
		elif action == "logout":
				if get_tree().root.has_node("AuthManager"): get_node("/root/AuthManager").logout()
				get_tree().change_scene_to_file("res://Scenes/login.tscn")

func _set_settings_status(message: String, is_error: bool = false):
		if _settings_status_label:
				_settings_status_label.text = message
				_settings_status_label.modulate = Color(1.0, 0.6, 0.6, 1.0) if is_error else Color(0.9, 1.0, 0.9, 1.0)

func _clear_settings_status():
		if _settings_status_label:
				_settings_status_label.text = ""
