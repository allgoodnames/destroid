extends Area2D

const SPEED = 1000;
const LIFETIME = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(LIFETIME).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	translate(Vector2.UP.rotated(rotation) * SPEED * delta);
	
func _on_body_entered(body):
	if(body.has_method('was_shot')):
		body.was_shot();
		if Main.instance:
			Main.instance.score += Main.instance.POINTS_PER_HIT;
		queue_free();
