extends Sprite2D

const SPEED = 100.0
const LIFETIME = 1.5
const MAX_SPREAD_DEGREES = 25.0   # Max random spread from initial rotation
const MIN_TUMBLE = 2.0
const MAX_TUMBLE = 6.0
const FADE_START_RATIO = 0.8  # Start fading at 80% of lifetime

var velocity: Vector2
var tumble_speed: float
var elapsed_time := 0.0

func _ready() -> void:
	# Random initial rotation for visual tumbling
	rotation = randf_range(0, TAU)
	
	# Pick a random spread angle for the explosion direction
	var spread = deg_to_rad(randf_range(-MAX_SPREAD_DEGREES, MAX_SPREAD_DEGREES))
	var direction = Vector2.UP.rotated(rotation + spread).normalized()
	
	# Set initial velocity along that direction
	velocity = direction * SPEED
	
	# Random tumble
	tumble_speed = randf_range(MIN_TUMBLE, MAX_TUMBLE) * (-1 if randf() < 0.5 else 1)

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	
	# Move fragment
	position += velocity * delta
	rotation += tumble_speed * delta

	# Fade out during the last part of lifetime
	var fade_ratio = elapsed_time / LIFETIME
	if fade_ratio > FADE_START_RATIO:
		var alpha_ratio = 1.0 - (fade_ratio - FADE_START_RATIO) / (1.0 - FADE_START_RATIO)
		modulate.a = alpha_ratio

	# Remove when lifetime ends
	if elapsed_time >= LIFETIME:
		queue_free()
