## [br]Expects to contain an array of [Marker3D]s as direct children, which are used to make sure a configurable portion of the unit is visible before officially considering them as "seen".
class_name SeenZone
extends VisionZone

## Signal emitted when this [SeenZone] is detected by one or more [SeeingZone]s.
signal seen_by_enemies(enemies : Array[EnemyUnit])

## The unit which owns this [SeenZone]. Can be friendly or enemy, as determining line of sight to another unit is relevant for both teams.
@export var unit : Unit

## The [Marker3D]s contained under this [SeenZone] as children.
var vision_targets : Array[Marker3D]:
	get():
		var result : Array[Marker3D]
		for point in get_children():
			if point is Marker3D:
				result.append(point)
		return result


func check_detection() -> void:
	var spotters : Array[EnemyUnit] = []
	var colliders = get_overlapping_areas()
	var seeing_zones = colliders.filter(func(collider): return collider is SeeingZone)
	for zone : SeeingZone in seeing_zones:
		if !zone.enemy.is_incapacitated():
			if zone.get_visibility_of_seen_zone(self):
				spotters.append(zone.enemy)
	if !spotters.is_empty():
		seen_by_enemies.emit(spotters)
