extends RigidBodyWrap

const ROTATION_SPEED = 3.8;
const THRUST_FORCE = 260;
const MAX_SPEED = 220.0;
const SHOT_COOLDOWN = 0.25;

var remaining_cooldown = 0;

@onready var sprite_2d: Sprite2D = $Sprite2D

var normal_texture = preload("res://assets/sprites/vector ship.png");
var invulnerable_texture = preload("res://assets/sprites/vector ship invulnerable.png");
var invulnerable:
	get:
		return invulnerable;
	set(value):
		invulnerable = value;
		if(sprite_2d):
			if(!invulnerable):
					sprite_2d.texture = normal_texture;
			else:
				sprite_2d.texture = invulnerable_texture;

signal has_died;

@onready var flame: Sprite2D = $Flame
@onready var danger_collider: Area2D = $DangerCollider

const bullet_scene = preload("res://scenes/bullet.tscn");

func _ready() -> void:
	invulnerable = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var thrust_dir = Vector2.UP.rotated(rotation).normalized();
	var actual_speed = linear_velocity.length();
	var rot_input := 0;
	if Input.is_action_pressed("rotate_cw"):
		rot_input += 1
		invulnerable = false;
	if Input.is_action_pressed("rotate_ccw"):
		rot_input -= 1
		invulnerable = false;
	angular_velocity = rot_input * ROTATION_SPEED;
	
	if(Input.is_action_pressed("thrust")):
		invulnerable = false;
		if(actual_speed < MAX_SPEED):
			apply_force(thrust_dir * THRUST_FORCE);
			flame.visible = true;
		elif linear_velocity.dot(thrust_dir) < 0:
			apply_force(thrust_dir * THRUST_FORCE);
			flame.visible = true;
	else:
		flame.visible = false;
		
	remaining_cooldown -= delta;
	if(remaining_cooldown <= 0 && Input.is_action_pressed("shoot")):
		invulnerable = false;
		remaining_cooldown = SHOT_COOLDOWN;
		shoot_bullet();

func shoot_bullet():
	var bullet = bullet_scene.instantiate();
	bullet.rotation = self.rotation;
	bullet.global_position = $Spawner.global_position;
	get_parent().add_child(bullet);

func _on_danger_collider_body_entered(_body: Node2D) -> void:
	if(!invulnerable):
		has_died.emit();
