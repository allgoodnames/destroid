extends Control

class_name Main

static var instance: Main  # global reference

const NUM_INITIAL_ASTEROIDS = 2;
const ASTEROID_SPAWN_RANGE_MIN = 150;
const ASTEROID_SPAWN_RANGE_MAX = 320;
const POINTS_PER_HIT = 100;

signal score_updated;
signal level_updated;
signal lives_updated;

signal game_over_triggered;

var lives:
	get:
		return lives;
	set(value):
		lives = value;
		lives_updated.emit(lives);
var score:
	get:
		return score;
	set(value):
		score = value;
		score_updated.emit(score);
var level:
	get:
		return level;
	set(value):
		level = value;
		level_updated.emit(level);

var player_node = null;

var player_scene = preload("res://scenes/player.tscn");
var asteroid_scene_large01 = preload("res://scenes/asteroid_large_1.tscn");
var asteroid_scene_large02 = preload("res://scenes/asteroid_large_2.tscn");
@onready var viewport_size = get_viewport().size;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.instance = self  # assign the static reference
	setup_new_game()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func setup_new_game():
	level = 1;
	setup_level(NUM_INITIAL_ASTEROIDS + level);
	score = 0;
	lives = 3;

func setup_level(num_asteroids):
	spawn_player(false);
	for i in num_asteroids:
		spawn_asteroid();
		
func spawn_player(respawn):
	if(respawn):
		if(player_node):
			player_node.queue_free();
		await get_tree().create_timer(2.0).timeout
	
	player_node = player_scene.instantiate();
	player_node.position = viewport_size/2;
	player_node.invulnerable = true;
	player_node.has_died.connect(_on_player_death);
	add_child(player_node);
	
func spawn_asteroid():
	var asteroid;
	if randi() % 2 == 0:
		asteroid = asteroid_scene_large01.instantiate();
	else:
		asteroid = asteroid_scene_large02.instantiate();
	asteroid.position = viewport_size/2.0 + (Utility.random_unit_vector2() * randf_range(ASTEROID_SPAWN_RANGE_MIN, ASTEROID_SPAWN_RANGE_MAX));
	add_child(asteroid);
	
func _on_player_death():
	if(lives <= 0):
		game_over();
		if(player_node):
			player_node.queue_free();
		return;
	lives -= 1;
	call_deferred("spawn_player", true);
		
func game_over():
	game_over_triggered.emit();

# TODO - Fix stage clear when all asteroids are deleted
# TODO - Display "Level X" for a brief while before the next stage starts
# TODO - Restart menu when all lives are done (clear scene and respawn everything for current level settings)
# TODO - Maybe life up every 5 000 points?
