class_name SeeingZone
extends VisionZone

signal friendly_seen(friendlies : Array[FriendlyUnit])

@export var enemy : EnemyUnit

func check_detection() -> void:
	var spotted : Array[FriendlyUnit] = []
	var colliders = get_overlapping_areas()
	var seen_zones = colliders.filter(func(collider): return collider is SeenZone)
	for zone : SeenZone in seen_zones:
		var vis_score = 0
		for point : VisibilityPoint in zone.vision_targets:
			if get_line_of_sight(point.global_position, zone.friendly):
				vis_score += 1
		DebugConsole.log("Enemy sees " + str(vis_score) + "/8 of friendly's vision points", 3)
		if vis_score > 2:
			spotted.append(zone.friendly)
	if !spotted.is_empty():
		friendly_seen.emit(spotted)