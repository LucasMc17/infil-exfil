## [br]Expects to contain an array of [VisibilityPoint]s as direct children, which are used to make sure a configurable portion of the unit is visible before officially considering them as "seen".
class_name SeenZone
extends VisionZone

## Signal emitted when this [SeenZone] is detected by one or more [SeeingZone]s.
signal seen_by_enemies(enemies : Array[EnemyUnit])

## The unit which owns this [SeenZone]. Can be friendly or enemy, as determining line of sight to another unit is relevant for both teams.
@export var unit : Unit

## The [VisibilityPoint]s contained under this [SeenZone] as children.
var vision_targets : Array[VisibilityPoint]:
	get():
		var result : Array[VisibilityPoint]
		for point in get_children():
			if point is VisibilityPoint:
				result.append(point)
		return result


func check_detection() -> void:
	var spotters : Array[EnemyUnit] = []
	var colliders = get_overlapping_areas()
	var seeing_zones = colliders.filter(func(collider): return collider is SeeingZone)
	for zone : SeeingZone in seeing_zones:
		var vis_score = 0
		for point : VisibilityPoint in vision_targets:
			if zone.get_line_of_sight(point.global_position, unit):
				vis_score += 1
		DebugConsole.log(str(vis_score) + "/8 of unit's vision points seen by enemy", 3)
		if vis_score > 1:
			spotters.append(zone.enemy)
	if !spotters.is_empty():
		seen_by_enemies.emit(spotters)
