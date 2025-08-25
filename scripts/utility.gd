class_name Utility

static func random_unit_vector2():
	var v = Vector2();
	v.x = randf_range(-1.0, 1.0);
	v.y = randf_range(-1.0, 1.0);
	return v.normalized();
