class_name SeeingZone
extends VisionZone

signal friendly_seen(friendlies : Array[FriendlyUnit])

@export var enemy : EnemyUnit

func test_visibility() -> void:
	var spotted : Array[FriendlyUnit] = []
	var colliders = get_overlapping_areas()
	var seen_zones = colliders.filter(func(collider): return collider is SeenZone)
	for zone : SeenZone in seen_zones:
		var vis_score = 0
		for point : VisibilityPoint in zone.vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision and collision.collider == zone.friendly:
				vis_score += 1
		DebugConsole.log("Enemy sees " + str(vis_score) + "/8 of friendly's vision points", 3)
		if vis_score > 2:
			spotted.append(zone.friendly)
	if !spotted.is_empty():
		friendly_seen.emit(spotted)