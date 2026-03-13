extends Node
class_name UIAnimations

## Global UI animation helper functions

static func fade_in(node: CanvasItem, duration: float = 0.5):
	"""Fades in a node"""
	node.modulate.a = 0.0
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "modulate:a", 1.0, duration)

static func fade_out(node: CanvasItem, duration: float = 0.5):
	"""Fades out a node"""
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "modulate:a", 0.0, duration)

static func slide_in_from_left(node: Control, duration: float = 0.6):
	"""Slides a node in from the left"""
	var original_pos = node.position
	node.position.x -= 300
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "position", original_pos, duration)

static func slide_in_from_right(node: Control, duration: float = 0.6):
	"""Slides a node in from the right"""
	var original_pos = node.position
	node.position.x += 300
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "position", original_pos, duration)

static func scale_pop_in(node: Control, duration: float = 0.5):
	"""Creates a pop-in scale animation"""
	node.scale = Vector2.ZERO
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", Vector2.ONE, duration)

static func bounce_button(button: Button):
	"""Creates a bounce effect on button press"""
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.3)

static func _kill_tactile_tween(button: Button):
	if button and button.has_meta("_tactile_tween"):
		var t: Variant = button.get_meta("_tactile_tween")
		if t is Tween and is_instance_valid(t):
			t.kill()

static func _tactile_animate(button: Button, target: Vector2, duration: float, trans: Tween.TransitionType = Tween.TRANS_BACK, ease_type: Tween.EaseType = Tween.EASE_OUT):
	if not button:
		return
	_kill_tactile_tween(button)
	var tween := button.create_tween()
	tween.set_trans(trans)
	tween.set_ease(ease_type)
	tween.tween_property(button, "scale", target, duration)
	button.set_meta("_tactile_tween", tween)

static func setup_tactile_button(button: Button, hover_scale_factor: float = 1.08, press_x: float = 1.12, press_y: float = 0.86):
	"""Adds squash, stretch, and bounce interactions to a button once."""
	if not button:
		return
	if button.has_meta("_tactile_setup") and bool(button.get_meta("_tactile_setup")):
		return

	button.set_meta("_tactile_setup", true)
	button.pivot_offset = button.size * 0.5
	if button.has_signal("resized"):
		button.resized.connect(func():
			button.pivot_offset = button.size * 0.5
		)

	button.mouse_entered.connect(func():
		_tactile_animate(button, Vector2.ONE * hover_scale_factor, 0.14)
	)
	button.mouse_exited.connect(func():
		_tactile_animate(button, Vector2.ONE, 0.16, Tween.TRANS_QUAD)
	)
	button.button_down.connect(func():
		_tactile_animate(button, Vector2(press_x, press_y), 0.07, Tween.TRANS_QUAD)
	)
	button.button_up.connect(func():
		_tactile_animate(button, Vector2.ONE * 1.05, 0.11)
		var release_tween := button.create_tween()
		release_tween.set_trans(Tween.TRANS_ELASTIC)
		release_tween.set_ease(Tween.EASE_OUT)
		release_tween.tween_property(button, "scale", Vector2.ONE, 0.24)
		button.set_meta("_tactile_tween", release_tween)
	)

static func hover_scale(button: Button, hover: bool):
	"""Scales button on hover"""
	var target_scale = Vector2(1.05, 1.05) if hover else Vector2.ONE
	var tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", target_scale, 0.2)

static func shake_node(node: Node2D, intensity: float = 5.0, _duration: float = 0.5):
	"""Shakes a node for error feedback"""
	var original_pos = node.position
	var tween = node.create_tween()
	tween.set_loops(5)
	tween.tween_property(node, "position", original_pos + Vector2(intensity, 0), 0.05)
	tween.tween_property(node, "position", original_pos - Vector2(intensity, 0), 0.05)
	tween.tween_callback(func(): node.position = original_pos)

static func pulse_glow(node: CanvasItem, duration: float = 1.0):
	"""Creates a pulsing glow effect"""
	var tween = node.create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "modulate", Color(1.5, 1.5, 1.5, 1), duration / 2.0)
	tween.tween_property(node, "modulate", Color(1, 1, 1, 1), duration / 2.0)

static func typing_effect(label: Label, text: String, speed: float = 0.05):
	"""Creates a typing effect for text"""
	label.text = ""
	for i in range(text.length()):
		label.text += text[i]
		await label.get_tree().create_timer(speed).timeout

static func float_up_and_fade(node: Control, distance: float = 50.0, duration: float = 1.0):
	"""Floats a node upward while fading out (good for +score popups)"""
	var tween = node.create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position:y", node.position.y - distance, duration)
	tween.tween_property(node, "modulate:a", 0.0, duration)
	await tween.finished
	node.queue_free()

static func scene_transition_fade(tree: SceneTree, scene_path: String, duration: float = 0.5):
	"""Transitions to a new scene with fade effect"""
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0.0
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tree.root.add_child(fade_overlay)
	
	# Fade out
	var tween = fade_overlay.create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, duration)
	await tween.finished
	
	# Change scene
	tree.change_scene_to_file(scene_path)
	
	# Fade in
	await tree.create_timer(0.1).timeout
	var tween2 = fade_overlay.create_tween()
	tween2.tween_property(fade_overlay, "modulate:a", 0.0, duration)
	await tween2.finished
	fade_overlay.queue_free()

static func screen_shake(camera: Camera2D, intensity: float = 10.0, duration: float = 0.3):
	"""Shakes the camera for impact effects"""
	var original_offset = camera.offset
	var shake_tween = camera.create_tween()
	shake_tween.set_loops(int(duration / 0.05))
	shake_tween.tween_callback(func():
		camera.offset = original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
	)
	shake_tween.tween_interval(0.05)
	await shake_tween.finished
	camera.offset = original_offset

static func apply_ethereal_float(node: Node2D, time_sec: float, amplitude: float = 4.0, rotation_degrees: float = 1.0, speed: float = 1.0, phase_offset: float = 0.0):
	"""Applies gentle sine-wave bob and micro-rotation around a stable base transform."""
	if not node:
		return
	if not node.has_meta("_ethereal_base_position"):
		node.set_meta("_ethereal_base_position", node.position)
		node.set_meta("_ethereal_base_rotation", node.rotation)

	var base_position: Vector2 = node.get_meta("_ethereal_base_position")
	var base_rotation: float = node.get_meta("_ethereal_base_rotation")
	var wave: float = (time_sec * speed) + phase_offset
	node.position = base_position + Vector2(0.0, sin(wave) * amplitude)
	node.rotation = base_rotation + deg_to_rad(sin(wave * 0.75) * rotation_degrees)
