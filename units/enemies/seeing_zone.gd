## Extension of a [VisionZone] specifically responsible for "seeing" [SeenZone]s which overlap with it.
class_name SeeingZone
extends VisionZone

## Signal emitted when the [SeeingZone] successfully detects one or more [FriendlyUnit]s.
signal friendly_seen(friendlies : Array[FriendlyUnit])

## The enemy unit which owns this [SeeingZone], since only enemies need a typical vision cone at this point in development.
@export var enemy : EnemyUnit

func check_detection() -> void:
	var spotted : Array[FriendlyUnit] = []
	var colliders = get_overlapping_areas()
	var seen_zones = colliders.filter(func(collider): return collider is SeenZone and collider.unit is FriendlyUnit)
	for zone : SeenZone in seen_zones:
		var vis_score = 0
		for point : VisibilityPoint in zone.vision_targets:
			if get_line_of_sight(point.global_position, zone.unit):
				vis_score += 1
		DebugConsole.log("Enemy sees " + str(vis_score) + "/8 of friendly's vision points", 3)
		if vis_score > 2:
			spotted.append(zone.unit)
	if !spotted.is_empty():
		friendly_seen.emit(spotted)