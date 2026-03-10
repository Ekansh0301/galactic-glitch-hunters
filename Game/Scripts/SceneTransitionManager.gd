extends Node
class_name SceneTransitionManager

## Manages scene transitions with various effects

enum TransitionType {
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	ZOOM_IN,
	ZOOM_OUT
}

static var transition_duration: float = 0.6
static var is_transitioning: bool = false

static func change_scene(tree: SceneTree, scene_path: String, type: TransitionType = TransitionType.FADE):
	"""Changes scene with specified transition effect"""
	if is_transitioning:
		return
	
	is_transitioning = true
	
	match type:
		TransitionType.FADE:
			await _fade_transition(tree, scene_path)
		TransitionType.SLIDE_LEFT:
			await _slide_transition(tree, scene_path, Vector2(-1, 0))
		TransitionType.SLIDE_RIGHT:
			await _slide_transition(tree, scene_path, Vector2(1, 0))
		TransitionType.SLIDE_UP:
			await _slide_transition(tree, scene_path, Vector2(0, -1))
		TransitionType.SLIDE_DOWN:
			await _slide_transition(tree, scene_path, Vector2(0, 1))
		TransitionType.ZOOM_IN:
			await _zoom_transition(tree, scene_path, true)
		TransitionType.ZOOM_OUT:
			await _zoom_transition(tree, scene_path, false)
	
	is_transitioning = false

static func _fade_transition(tree: SceneTree, scene_path: String):
	"""Fade to black transition"""
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	tree.root.add_child(overlay)
	
	# Fade out
	var tween = overlay.create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, transition_duration / 2.0)
	await tween.finished
	
	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.create_timer(0.1).timeout
	
	# Fade in
	var tween2 = overlay.create_tween()
	tween2.tween_property(overlay, "modulate:a", 0.0, transition_duration / 2.0)
	await tween2.finished
	overlay.queue_free()

static func _slide_transition(tree: SceneTree, scene_path: String, direction: Vector2):
	"""Slide transition in specified direction"""
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	
	var viewport_size = tree.root.get_viewport().get_visible_rect().size
	overlay.position = -direction * viewport_size
	tree.root.add_child(overlay)
	
	# Slide in
	var tween = overlay.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(overlay, "position", Vector2.ZERO, transition_duration / 2.0)
	await tween.finished
	
	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.create_timer(0.1).timeout
	
	# Slide out
	var tween2 = overlay.create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(overlay, "position", direction * viewport_size, transition_duration / 2.0)
	await tween2.finished
	overlay.queue_free()

static func _zoom_transition(tree: SceneTree, scene_path: String, zoom_in: bool):
	"""Zoom in or out transition"""
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 100
	
	var start_scale = Vector2(5, 5) if zoom_in else Vector2(0.2, 0.2)
	var end_scale = Vector2.ONE
	overlay.scale = start_scale
	overlay.pivot_offset = overlay.size / 2.0
	
	tree.root.add_child(overlay)
	
	# Zoom effect with fade
	var tween = overlay.create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(overlay, "scale", end_scale, transition_duration / 2.0)
	tween.tween_property(overlay, "modulate:a", 1.0, transition_duration / 2.0)
	await tween.finished
	
	# Change scene
	tree.change_scene_to_file(scene_path)
	await tree.create_timer(0.1).timeout
	
	# Fade out
	var tween2 = overlay.create_tween()
	tween2.tween_property(overlay, "modulate:a", 0.0, transition_duration / 2.0)
	await tween2.finished
	overlay.queue_free()
