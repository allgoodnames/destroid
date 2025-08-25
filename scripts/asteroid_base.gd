extends RigidBodyWrap

const INITIAL_FORCE = 70;
const SPIN_SPEED = 0.25;
const NUM_OF_CHILDREN = 2;

@export var debris_scene1 : PackedScene;
@export var debris_scene2 : PackedScene;
@export var speed_multiplier: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_impulse(Utility.random_unit_vector2() * INITIAL_FORCE * speed_multiplier);
	angular_velocity = SPIN_SPEED * ( -1 if randf() < 0.5 else 1 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func was_shot():
	call_deferred("spawn_debris");
	queue_free()
	
func spawn_debris():
	if debris_scene1 && debris_scene2:
		for i in NUM_OF_CHILDREN:
			var d;
			if(randf() < 0.5):
				d = debris_scene1.instantiate()
			else:
				d = debris_scene2.instantiate()
			d.global_position = global_position
			get_parent().add_child(d)
