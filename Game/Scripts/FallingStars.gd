extends Node2D
class_name FallingStars

## Particle-based falling stars effect for backgrounds

@export var spawn_rate: float = 0.5  # Stars per second
@export var star_speed_min: float = 50.0
@export var star_speed_max: float = 200.0
@export var star_size_min: float = 2.0
@export var star_size_max: float = 6.0
@export var max_stars: int = 50
@export var enable_trails: bool = true

var stars: Array = []
var spawn_timer: float = 0.0
var viewport_size: Vector2

func _ready():
	viewport_size = get_viewport_rect().size

func _process(delta: float):
	spawn_timer += delta
	
	# Spawn new stars
	if spawn_timer >= 1.0 / spawn_rate and stars.size() < max_stars:
		_spawn_star()
		spawn_timer = 0.0
	
	# Update and remove stars
	for i in range(stars.size() - 1, -1, -1):
		var star = stars[i]
		star.position += star.velocity * delta
		
		# Fade out as it falls
		star.modulate.a = 1.0 - (star.position.y / viewport_size.y)
		
		# Remove if off screen
		if star.position.y > viewport_size.y + 50:
			star.queue_free()
			stars.remove_at(i)
	
	queue_redraw()

func _spawn_star():
	"""Creates a new falling star"""
	var star = Node2D.new()
	star.name = "Star"
	
	# Random position at top
	star.position = Vector2(
		randf() * viewport_size.x,
		-20
	)
	
	# Random velocity (downward and slightly angled)
	var speed = randf_range(star_speed_min, star_speed_max)
	var angle = randf_range(-0.3, 0.3)  # Slight angle
	star.velocity = Vector2(sin(angle), 1.0).normalized() * speed
	
	# Random size and brightness
	star.star_size = randf_range(star_size_min, star_size_max)
	star.brightness = randf_range(0.6, 1.0)
	
	add_child(star)
	stars.append(star)

func _draw():
	"""Draws all stars"""
	for star in stars:
		var color = Color(1, 1, 1, star.modulate.a * star.brightness)
		
		# Draw star as a cross shape
		var size = star.star_size
		draw_line(
			star.position + Vector2(-size, 0),
			star.position + Vector2(size, 0),
			color,
			2.0
		)
		draw_line(
			star.position + Vector2(0, -size),
			star.position + Vector2(0, size),
			color,
			2.0
		)
		
		# Draw glow
		draw_circle(star.position, size * 0.8, Color(color.r, color.g, color.b, color.a * 0.3))
		
		# Draw trail if enabled
		if enable_trails:
			var trail_length = star.star_size * 3
			var trail_end = star.position - star.velocity.normalized() * trail_length
			draw_line(star.position, trail_end, Color(color.r, color.g, color.b, color.a * 0.5))
