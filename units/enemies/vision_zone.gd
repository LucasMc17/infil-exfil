class_name VisionZone
extends Area3D

# TODO: Will support an array later.
signal friendly_seen(friendly : FriendlyUnit)

var _check_queued := false

func queue_vision_test():
	_check_queued = true


func _test_visibility():
	_check_queued = false
	var colliders = get_overlapping_areas()
	var visible_zones = colliders.filter(func(collider): return collider is VisibleZone)
	for zone : VisibleZone in visible_zones:
		DebugConsole.log('potential sighting')
		var vis_score = 0
		for point : VisibilityPoint in zone.vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision and collision.collider == zone.friendly:
				vis_score += 1
		DebugConsole.log(vis_score)
		if vis_score > 1:
			friendly_seen.emit(zone.friendly)


func _physics_process(_delta: float) -> void:
	if _check_queued:
		_test_visibility()