extends Control

@export var score_label : Label;
@export var level_label : Label;
@export var lives_label : Label;

@onready var lives_container: HBoxContainer = $HBoxContainer;

var life_icon = preload("res://scenes/life.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_main_score_updated(score):
	if(score_label):
		score_label.text = "%d" % score;

func _on_main_level_updated(level):
	if(level_label):
		level_label.text = "Level %d" % level;

func _on_main_lives_updated(lives):
	if(lives_container):
		for child in lives_container.get_children():
			child.queue_free()
		for i in range(lives):
			var icon = life_icon.instantiate()
			lives_container.add_child(icon)
