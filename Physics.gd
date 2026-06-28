class_name Physics

static func get_friction(body: CharacterBody3D, groups: Dictionary) -> float:
	var collision: KinematicCollision3D = body.get_last_slide_collision()
	if collision:
		var hit_body = collision.get_collider()
		#var projection = body.velocity.project(collision.get_normal())
		#var perp = body.velocity - projection
		if hit_body is StaticBody3D:
			for group in groups:
				if hit_body.is_in_group(group):
					return groups[group]
		return 1
	return 0
