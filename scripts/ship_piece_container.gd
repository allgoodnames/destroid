extends Node2D

@export var piece_scenes: Array[PackedScene] = []        # Assign three piece scenes
@export var final_positions: Array[Vector2] = []         # Final positions for each piece
@export var final_rotations: Array[float] = []           # Final rotation for each piece
@export var duration: float = 1.5                        # Time to complete animation
@export var start_rotation_offset_degrees: float = 90.0  # Angle away from final rotation
@export var start_distance: float = 100.0                # Distance pieces start away from final positions

var pieces: Array[Node2D] = []
var start_positions: Array[Vector2] = []
var start_rotations: Array[float] = []
var elapsed_time: float = 0.0

func _ready():
	for i in piece_scenes.size():
		var piece = piece_scenes[i].instantiate() as Node2D
		add_child(piece)
		pieces.append(piece)

		# Start positions farther out
		match i:
			0: piece.position = final_positions[i] + Vector2(0, -start_distance)      # From top
			1: piece.position = final_positions[i] + Vector2(-start_distance*0.66, start_distance*0.66)     # From bottom-left
			2: piece.position = final_positions[i] + Vector2(start_distance*0.66, start_distance*0.66)      # From bottom-right
			_: piece.position = final_positions[i]
		start_positions.append(piece.position)

		# Start rotations opposite from final rotation
		if final_rotations.size() > i:
			start_rotations.append(final_rotations[i] + deg_to_rad(start_rotation_offset_degrees))
		else:
			start_rotations.append(deg_to_rad(start_rotation_offset_degrees))

		piece.rotation = start_rotations[i]
		piece.modulate.a = 0.0  # Start transparent

func _process(delta: float) -> void:
	elapsed_time += delta
	var t = clamp(elapsed_time / duration, 0, 1)

	# Ease-out: starts fast, slows down at end
	var eased_t = 1.0 - pow(1.0 - t, 3)

	for i in pieces.size():
		pieces[i].position = start_positions[i].lerp(final_positions[i], eased_t)
		pieces[i].rotation = lerp_angle(start_rotations[i], final_rotations[i], eased_t)
		pieces[i].modulate.a = eased_t

	if t >= 1.0:
		for piece in pieces:
			piece.visible = false  # or piece.queue_free() if you want to remove them entirely
		queue_free()  # still remove the container if desired
