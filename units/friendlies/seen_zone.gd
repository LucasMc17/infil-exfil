class_name SeenZone
extends VisionZone

signal seen_by_enemies(enemies : Array[EnemyUnit])

@export var friendly : FriendlyUnit

var vision_targets : Array[VisibilityPoint]:
	get():
		var result : Array[VisibilityPoint]
		for point in get_children():
			if point is VisibilityPoint:
				result.append(point)
		return result


func check_detection() -> void:
	# _detection_check_queued = false
	var spotters : Array[EnemyUnit] = []
	var colliders = get_overlapping_areas()
	var seeing_zones = colliders.filter(func(collider): return collider is SeeingZone)
	for zone : SeeingZone in seeing_zones:
		var vis_score = 0
		for point : VisibilityPoint in vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(zone.global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision and collision.collider == friendly:
				vis_score += 1
		DebugConsole.log(str(vis_score) + "/8 of friendly's vision points seen by enemy", 3)
		if vis_score > 1:
			spotters.append(zone.enemy)
	if !spotters.is_empty():
		seen_by_enemies.emit(spotters)




# func _physics_process(_delta: float) -> void:
# 	if _detection_check_queued:
# 		_check_detection()