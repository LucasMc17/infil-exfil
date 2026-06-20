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
	var spotters : Array[EnemyUnit] = []
	var colliders = get_overlapping_areas()
	var seeing_zones = colliders.filter(func(collider): return collider is SeeingZone)
	for zone : SeeingZone in seeing_zones:
		var vis_score = 0
		for point : VisibilityPoint in vision_targets:
			if zone.get_line_of_sight(point.global_position, friendly):
				vis_score += 1
		DebugConsole.log(str(vis_score) + "/8 of friendly's vision points seen by enemy", 3)
		if vis_score > 1:
			spotters.append(zone.enemy)
	if !spotters.is_empty():
		seen_by_enemies.emit(spotters)
