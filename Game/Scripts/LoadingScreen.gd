extends Control

var original_ship_pos = Vector2.ZERO
var original_ship_rotation: float = 0.0
var motion_time: float = 0.0

@onready var bias_label: Label = null

const PARALLAX_LAYERS := [
	{"path": "res://Assets/5446991.jpg", "speed": 18.0, "alpha": 0.22},
	{"path": "res://Assets/digital-art-dark-cosmic-night-sky.jpg", "speed": 32.0, "alpha": 0.30},
	{"path": "res://Assets/2206_w023_n003_2469b_p1_2469.jpg", "speed": 56.0, "alpha": 0.24}
]

var _parallax_state: Array[Dictionary] = []

# 1. The List of Quotes
func _ready():
	print("=== LOADING SCREEN ===")
	# Ensure scene is visible
	self.modulate.a = 1.0
	MusicManager.play_track(MusicManager.TRACK_DIGITAL_SUNSET)
	var LM = get_node("/root/LanguageManager")

	# Translated quotes
	var educational_quotes = [
		LM.t("loading_tip_1"),
		LM.t("loading_tip_2"),
		LM.t("loading_tip_3"),
		LM.t("loading_tip_4"),
		LM.t("loading_tip_5"),
		LM.t("loading_tip_6"),
	]

	if has_node("SpaceShip"):
		original_ship_pos = $SpaceShip.position
		original_ship_rotation = $SpaceShip.rotation

	if has_node("Label"):
		$Label.text = LM.t("loading_title")

	if has_node("QuoteLabel"):
		$QuoteLabel.text = educational_quotes.pick_random()
	
	# Find or create bias label
	if has_node("BiasLabel"):
		bias_label = $BiasLabel

	_create_parallax_layers()
	
	# Update bias display
	_update_bias_display()
	
	# 3. The Wait Timer (The Loading part)
	await get_tree().create_timer(3.0).timeout
	
	print("Loading complete, moving to PlanetView...")
	
	# Fade out before transitioning
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	# 4. Move to next scene
	get_tree().change_scene_to_file("res://Scenes/PlanetView.tscn")

func _create_parallax_layers():
	var viewport_size: Vector2 = get_viewport_rect().size
	for layer_config in PARALLAX_LAYERS:
		var texture: Texture2D = load(layer_config.path)
		if texture == null:
			continue

		var layer := Control.new()
		layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(layer)

		var tile_width: float = maxf(
			viewport_size.x,
			float(texture.get_width()) * (viewport_size.y / maxf(1.0, float(texture.get_height())))
		)

		var tile_a := TextureRect.new()
		tile_a.texture = texture
		tile_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile_a.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tile_a.position = Vector2.ZERO
		tile_a.size = Vector2(tile_width, viewport_size.y)
		tile_a.modulate.a = float(layer_config.alpha)
		layer.add_child(tile_a)

		var tile_b := TextureRect.new()
		tile_b.texture = texture
		tile_b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile_b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tile_b.position = Vector2(tile_width, 0)
		tile_b.size = Vector2(tile_width, viewport_size.y)
		tile_b.modulate.a = float(layer_config.alpha)
		layer.add_child(tile_b)

		_parallax_state.append({
			"tile_a": tile_a,
			"tile_b": tile_b,
			"speed": float(layer_config.speed),
			"tile_width": tile_width
		})

		# Keep parallax behind labels and ship.
		move_child(layer, 1)

func _update_bias_display():
	"""Updates the bias meter display during loading"""
	if bias_label and has_node("/root/GameManager"):
		var current_bias = GameManager.bias_meter
		bias_label.text = "Bias: " + str(int(current_bias)) + "%"
		
		# Color code based on bias level
		if current_bias > 75:
			bias_label.modulate = Color(1, 0.3, 0.3, 1)  # Red
		elif current_bias < 25:
			bias_label.modulate = Color(0.3, 0.8, 1, 1)  # Cyan
		else:
			bias_label.modulate = Color(0.7, 1, 0.7, 1)  # Green



func _process(delta):
	motion_time += delta

	for layer_data in _parallax_state:
		var tile_a: TextureRect = layer_data.tile_a
		var tile_b: TextureRect = layer_data.tile_b
		var speed: float = layer_data.speed
		var tile_width: float = layer_data.tile_width

		tile_a.position.x -= speed * delta
		tile_b.position.x -= speed * delta

		if tile_a.position.x <= -tile_width:
			tile_a.position.x = tile_b.position.x + tile_width
		if tile_b.position.x <= -tile_width:
			tile_b.position.x = tile_a.position.x + tile_width

	if has_node("SpaceShip"):
		var bob_y := sin(motion_time * 2.2) * 5.0
		var sway_x := sin(motion_time * 1.3) * 2.0
		var micro_roll := sin(motion_time * 1.7) * 0.025
		$SpaceShip.position = original_ship_pos + Vector2(sway_x, bob_y)
		$SpaceShip.rotation = original_ship_rotation + micro_roll
