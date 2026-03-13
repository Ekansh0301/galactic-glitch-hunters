extends Control

@onready var name_input = $CenterContainer/MainPanel/NameInput
@onready var pass_input = $CenterContainer/MainPanel/PasswordInput
@onready var error_label = $CenterContainer/MainPanel/ErrorLabel

func _ready():
	# Ensure scene is visible
	self.modulate.a = 1.0
	MusicManager.play_track(MusicManager.TRACK_SIGNAL_TO_NOISE)
	_start_glitch_effect()
	_apply_translations()
	_setup_animations()
func _start_glitch_effect():
	# Get the Title Label (Adjust path to your actual Title Label)
	var title = $CenterContainer/MainPanel/TitleLabel
	
	# Create a loop for the glitch
	var glitch_timer = Timer.new()
	add_child(glitch_timer)
	glitch_timer.wait_time = randf_range(2.0, 5.0) # Glitch every 2-5 seconds
	glitch_timer.timeout.connect(func():
		_trigger_glitch(title)
		glitch_timer.wait_time = randf_range(2.0, 5.0) # Randomize next interval
	)
	glitch_timer.start()

func _trigger_glitch(target: Control):
	var original_pos = target.position
	var original_modulate = target.modulate
	
	# Create a fast, jerky tween
	var tween = create_tween()
	tween.set_loops(3) # Shake 3 times
	
	# Randomly offset position
	tween.tween_property(target, "position", original_pos + Vector2(randf_range(-5, 5), randf_range(-3, 3)), 0.05)
	# Flash a glitch color (e.g., Cyan or Magenta)
	tween.tween_property(target, "modulate", Color.CYAN, 0.05)
	
	# Reset
	tween.finished.connect(func():
		target.position = original_pos
		target.modulate = original_modulate
		
	)
func _setup_animations():
	"""Sets up entry animations and button hover effects"""
	# Fade in the main panel
	var panel = $CenterContainer/MainPanel
	panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.6)
	
	# Setup button hover effects
	var buttons = [
		$CenterContainer/MainPanel/LoginButton,
		$CenterContainer/MainPanel/GuestLoginButton,
		$CenterContainer/MainPanel/ButtonRow/Signup,
		$CenterContainer/MainPanel/ButtonRow/LanguageButton
	]
	for button in buttons:
		if button:
			button.mouse_entered.connect(_on_button_hover.bind(button, true))
			button.mouse_exited.connect(_on_button_hover.bind(button, false))
			button.pressed.connect(_on_button_pressed.bind(button))
	# ZERO-GRAVITY FLOAT
	# We use a separate tween for the continuous loop
	var float_tween = create_tween().set_loops() # Infinite loop
	
	# Move up 10 pixels over 2 seconds, slightly easing in/out
	float_tween.tween_property(panel, "position:y", panel.position.y - 10, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Move back down
	float_tween.tween_property(panel, "position:y", panel.position.y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# 1. Capture the starting state so we don't drift off-screen forever
	#_start_pos = panel.position
	#_start_rot = panel.rotation_degrees
	#
	## 2. Start the organic wandering
	#_drift_element(panel)
	
#func _drift_element(target: Control):
	## SETTINGS: Tweak these to change the "floatiness"
	#var dist_limit = 12.0     # Max pixels to drift from center
	#var rot_limit = 2.0       # Max degrees to tilt
	#var time_min = 2.5        # Min time to reach next point
	#var time_max = 4.5        # Max time to reach next point
	#
	## 1. Calculate a random target offset based on the ORIGINAL position
	#var target_pos = _start_pos + Vector2(
		#randf_range(-dist_limit, dist_limit),
		#randf_range(-dist_limit, dist_limit)
	#)
	#
	## 2. Calculate a random slight rotation
	#var target_rot = _start_rot + randf_range(-rot_limit, rot_limit)
	#
	## 3. Pick a random speed for this specific movement
	#var duration = randf_range(time_min, time_max)
	#
	## 4. Create the Tween
	#var tween = create_tween()
	#tween.set_parallel(true) # Animate Pos and Rot at the same time
	#tween.set_ease(Tween.EASE_IN_OUT)
	#tween.set_trans(Tween.TRANS_SINE) # Sine is best for "floating"
	#
	#tween.tween_property(target, "position", target_pos, duration)
	#tween.tween_property(target, "rotation_degrees", target_rot, duration)
	#
	## 5. RECURSION: When this drift finishes, start a new one!
	#tween.chain().tween_callback(_drift_element.bind(target))

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

func _apply_translations():
	var LM = get_node("/root/LanguageManager")
	# Placeholders
	if name_input:
		name_input.placeholder_text = LM.t("placeholder_name")
	if pass_input:
		pass_input.placeholder_text = LM.t("placeholder_password")
		pass_input.secret = true
	if error_label:
		error_label.text = ""
	# Buttons — new paths
	if has_node("CenterContainer/MainPanel/LoginButton"):
		$CenterContainer/MainPanel/LoginButton.text = LM.t("btn_login")
	if has_node("CenterContainer/MainPanel/GuestLoginButton"):
		$CenterContainer/MainPanel/GuestLoginButton.text = LM.t("btn_guest")
	if has_node("CenterContainer/MainPanel/ButtonRow/LanguageButton"):
		$CenterContainer/MainPanel/ButtonRow/LanguageButton.text = LM.t("btn_change_language")
	if has_node("CenterContainer/MainPanel/ButtonRow/Signup"):
		$CenterContainer/MainPanel/ButtonRow/Signup.text = LM.t("signup_link")

func _on_login_button_pressed():
	var LM = get_node("/root/LanguageManager")
	if name_input.text.is_empty() or pass_input.text.is_empty():
		_error(LM.t("err_fill_fields"))
		return
	var success = AuthManager.authenticate(name_input.text, pass_input.text)
	if success:
		_redirect()
	else:
		_error(LM.t("err_invalid_creds"))

func _on_guest_login_button_pressed():
	var LM = get_node("/root/LanguageManager")
	if name_input.text.is_empty():
		_error(LM.t("err_enter_name"))
		return
	print("=== GUEST LOGIN ===")
	GameManager.player_name = name_input.text
	GameManager.is_logged_in = true
	_redirect()

func _on_signup_link_pressed():
	get_tree().change_scene_to_file("res://Scenes/signup.tscn")

func _on_signup_pressed():
	_on_signup_link_pressed()

func _on_language_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/LanguageSelect.tscn")

func _error(msg: String):
	if error_label:
		error_label.text = msg
		error_label.modulate = Color.RED
		# Shake animation for error
		var original_pos = error_label.position
		var tween = create_tween()
		tween.set_loops(4)
		tween.tween_property(error_label, "position:x", original_pos.x + 5, 0.05)
		tween.tween_property(error_label, "position:x", original_pos.x - 5, 0.05)
		tween.finished.connect(func(): error_label.position = original_pos)

func _redirect():
	# Fade out before changing scene
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/Character_Creation.tscn")
