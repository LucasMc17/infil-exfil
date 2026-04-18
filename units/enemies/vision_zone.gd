class_name VisionZone
extends Area3D

var _check_queued := false

func queue_vision_test():
	_check_queued = true


func _test_visibility():
	# force_update_transform()
	_check_queued = false
	var colliders = get_overlapping_areas()
	var visible_zones = colliders.filter(func(collider): return collider is VisibleZone)
	for zone : VisibleZone in visible_zones:
		print('potential sighting')
		var vis_score = 0
		for point : VisibilityPoint in zone.vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision and collision.collider == zone.friendly:
				vis_score += 1
		print(vis_score)
		if vis_score > 1:
			print("I see ya.")


func _physics_process(_delta: float) -> void:
	if _check_queued:
		_test_visibility()