class_name VisionZone
extends Area3D

var _check_queued := false

func queue_vision_test():
	_check_queued = true


func _test_visibility():
	force_update_transform()
	_check_queued = false
	var colliders = get_overlapping_bodies()
	var friendlies = colliders.filter(func(collider): return collider is FriendlyUnit)
	for friendly : FriendlyUnit in friendlies:
		print('potential sighting')
		var vis_score = 0
		for point : VisibilityPoint in friendly.vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision.collider == friendly:
				vis_score += 1
			# var ray_from = project_ray_origin(mouse_pos)
			# var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000

			# var ray_params = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
			# var result = get_world_3d().direct_space_state.intersect_ray(ray_params)
			# _collision_probe.look_at(point.global_position)
			# if _collision_probe.get_collider() == friendly:
			# 	vis_score += 1
		print(vis_score)
		if vis_score > 1:
			print("I see ya.")


func _physics_process(_delta: float) -> void:
	if _check_queued:
		_test_visibility()