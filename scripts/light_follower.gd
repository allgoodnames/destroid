extends PathFollow2D

@export var speed = 22.0  # pixels per second

func _ready() -> void:
	# randomize starting position along the path
	progress_ratio = randf()  # random float between 0.0 and 1.0

func _process(delta: float) -> void:
	progress += speed * delta
