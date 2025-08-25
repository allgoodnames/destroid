extends RigidBody2D
class_name RigidBodyWrap

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	wrap_to_viewport(state)

func wrap_to_viewport(state: PhysicsDirectBodyState2D) -> void:
	# Determine the sprite node (works if you have a child called Sprite2D)
	if not has_node("Sprite2D"):
		return

	var sprite_node: Sprite2D = $Sprite2D
	# Get the sprite size accounting for scaling
	var size: Vector2 = sprite_node.get_rect().size * sprite_node.scale
	# Get the current viewport size (dynamic, handles window resize)
	var viewport_size: Vector2 = get_viewport_rect().size

	var pos: Vector2 = state.transform.origin

	# Wrap horizontally
	if pos.x + size.x / 2 < 0:
		pos.x = viewport_size.x + size.x / 2
	elif pos.x - size.x / 2 > viewport_size.x:
		pos.x = -size.x / 2

	# Wrap vertically
	if pos.y + size.y / 2 < 0:
		pos.y = viewport_size.y + size.y / 2
	elif pos.y - size.y / 2 > viewport_size.y:
		pos.y = -size.y / 2

	state.transform.origin = pos
