extends RigidBodyWrap

const ROTATION_SPEED = 3.5;
const THRUST_FORCE = 260;
const MAX_SPEED = 220.0;
const SHOT_COOLDOWN = 0.35;
const LIGHT_MAX = 2
const LIGHT_MIN = 0.0
const FADE_TIME = 0.8
const WRECK_PARTS = 5;
var remaining_cooldown = 0;

@onready var sprite_2d: Sprite2D = $Sprite2D

var normal_texture = preload("res://assets/sprites/vector ship.png");
var invulnerable_texture = preload("res://assets/sprites/vector ship invulnerable.png");
var building;
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
@onready var grace_collider: Area2D = $GraceCollider
@onready var light: PointLight2D = $PointLight2D


const bullet_scene = preload("res://scenes/bullet.tscn");
const wreck_scene = preload("res://scenes/wreck.tscn");

func _ready() -> void:
	invulnerable = true;
	building = true;
	sprite_2d.modulate.a = 0.0  # start fully transparent
	await get_tree().create_timer(2).timeout
	building = false;

const FADE_DURATION := 1.5
const FADE_DELAY := 0.8

var fade_elapsed := 0.0
var fade_started := false

func _process(delta: float) -> void:
	if not fade_started:
		if fade_elapsed < FADE_DELAY:
			fade_elapsed += delta
		else:
			fade_started = true
			fade_elapsed = 0.0  # start counting fade
	elif fade_elapsed < FADE_DURATION:
		fade_elapsed += delta
		var t = clamp(fade_elapsed / FADE_DURATION, 0, 1)
		sprite_2d.modulate.a = t

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var thrust_dir = Vector2.UP.rotated(rotation).normalized();
	var actual_speed = linear_velocity.length();
	
	if(!building):
		var rot_input := 0;
		if Input.is_action_pressed("rotate_cw"):
			rot_input += 1
		if Input.is_action_pressed("rotate_ccw"):
			rot_input -= 1
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
		if(Input.is_action_pressed("shoot")):
			if Engine.time_scale != 0.75: # don’t set it every frame
				Engine.time_scale = 0.75
			if(remaining_cooldown <= 0):
				invulnerable = false;
				remaining_cooldown = SHOT_COOLDOWN;
				shoot_bullet();
		else:
			if Engine.time_scale != 1.0:
				Engine.time_scale = 1.0

func shoot_bullet():
	var bullet = bullet_scene.instantiate();
	bullet.rotation = self.rotation;
	bullet.global_position = $Spawner.global_position;
	get_parent().add_child(bullet);

func _on_danger_collider_body_entered(body: Node2D) -> void:
	if(!invulnerable):
		if(body.graze_points):
			Main.instance.score -= body.graze_points;
		else:
			Main.instance.score -= Main.instance.POINTS_PER_GRACE;
		for i in WRECK_PARTS:
			var wreck = wreck_scene.instantiate();
			wreck.rotation = self.rotation;
			wreck.global_position = $Spawner.global_position;
			get_parent().add_child(wreck);
		has_died.emit();

func _on_grace_collider_body_entered(body: Node2D) -> void:
	if(!invulnerable):
		var points;
		if(body.graze_energy && body.graze_points):
			light.energy = body.graze_energy;
			points = body.graze_points;
		else:
			light.energy = LIGHT_MAX;
			points = Main.instance.POINTS_PER_GRACE
		var tween = create_tween()
		tween.tween_property(light, "energy", LIGHT_MIN, FADE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		if Main.instance:
			Main.instance.score += points;
