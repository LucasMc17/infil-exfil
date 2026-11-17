## An extension of the [Area3D] node, which monitors for detection of and by other [VisionZone]s.
## [br]It is extended by two interconnected classes: [SeeingZone] which can detect [SeenZone]s which enter it, and [SeenZone], which can be detected by [SeeingZone]s it overlaps.
@abstract class_name VisionZone
extends Area3D

## Use the [test_line_of_sight] func above to determine if another seen zone (usually belonging to another unit) is visible to this unit.
func get_visibility_of_seen_zone(zone : SeenZone, use_override := false, position_override := Vector3.ZERO) -> bool:
	var vis_score = 0
	for point : Marker3D in zone.vision_targets:
		if Level.current.test_line_of_sight(position_override if use_override else global_position, point.global_position, zone.unit):
			vis_score += 1
	return vis_score > 2


## Determines whether this [VisionZone] is currently detecting or being detected by any other [VisionZone]s.
@abstract func check_detection() -> void
