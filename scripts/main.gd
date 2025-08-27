extends Control

class_name Main

static var instance: Main  # global reference

const INITIAL_LEVEL = 1;
const INITIAL_LIVES = 3;
const ONE_UP_PER_SCORE = 10000;

const ASTEROIDS_PER_LEVEL = [3, 5, 7, 12, 17, 22, 30, 40, 50];
const ASTEROID_SPAWN_RANGE_MIN = 150;
const ASTEROID_SPAWN_RANGE_MAX = 320;
const POINTS_PER_HIT = 100;
const POINTS_PER_GRACE = 300;

signal score_updated;
signal level_updated;
signal lives_updated;
signal next_level;

signal game_over_triggered;
signal game_restart;

var player_is_spawning = false;

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
		var old_score = score
		score = value
		score_updated.emit(score)
		if old_score != null and int(old_score / ONE_UP_PER_SCORE) < int(score / ONE_UP_PER_SCORE):
			lives += 1
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
@onready var viewport_size = get_viewport_rect().size

func _ready() -> void:
	Main.instance = self  # assign the static reference
	setup_new_game()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart") && !player_is_spawning:
		game_restart.emit();
		if(player_node):
			player_node.queue_free();
		setup_new_game();
	
func setup_new_game():
	level = INITIAL_LEVEL;
	setup_level(ASTEROIDS_PER_LEVEL[level-1], true);
	score = 0;
	lives = INITIAL_LIVES;

func setup_level(num_asteroids, initial):
	spawn_player(!initial);
	for asteroid in get_tree().get_nodes_in_group("asteroids"):
		asteroid.queue_free();
	for i in num_asteroids:
		call_deferred("spawn_asteroid");
		
func spawn_player(respawn):
	if(respawn):
		player_is_spawning = true;
		if(player_node):
			player_node.queue_free();
		await get_tree().create_timer(3.0).timeout
		player_is_spawning = false;
	
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
	asteroid.add_to_group("asteroids");
	
func _on_asteroid_obliteration():
	if get_tree().get_nodes_in_group("asteroids").size()-1 == 0:
		level += 1
		next_level.emit(level);

		if(level <= ASTEROIDS_PER_LEVEL.size()):
			setup_level(ASTEROIDS_PER_LEVEL[level-1], false);
		else:
			setup_level(ASTEROIDS_PER_LEVEL[ASTEROIDS_PER_LEVEL.size()-1] + level, false);
	
func _on_player_death():
	if(lives <= 0):
		game_over();
		if(player_node):
			player_node.queue_free();
		return;
	lives -= 1;
	call_deferred("spawn_player", true);
		
func game_over():
	game_over_triggered.emit(score);

# TODO - Freeze frame on hits
# TODO - Pulse score counter in white when it goes up

# TODO - Some enviromental effect that forces the player to hurry and finish the level. 
# TODO - Solar winds maybe? A red gradient around edges, and then do a massive pulse to all asteroids in a random direction. The second wind should come quicker and from another direction
#		Don't start countdown to solar wind until the player steps out of invulnerability
#		Maybe have a total level timer of 30 seconds before the wind. and then grazing asteroids (+1/+3/+5 seconds), and shooting them (+1 second) can push the timer back, but no further than to 15 seconds remaining.
#		Make it so that the game shifts down to widescreen instead. Pre-empt with a red light. Then have the red follow the walls as they close in
# TODO - When ship respawns, animate pieces fading in and coming together as the ship, and push back solar wind by 10 seconds.

# TODO - Save scores to file (or localstorage when using the web version)
# TODO - That alternating tone as 'music'
# TODO - SFX
