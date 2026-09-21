## Extension of a [VisionZone] specifically responsible for "seeing" [SeenZone]s which overlap with it.
class_name SeeingZone
extends VisionZone

# NOTE: I'm not in love with having both a shapecast and an area3d covering the same exact polygon of space. But this allows me to have frame-instant detections when this unit initiates a detection check (the shapecast) AND to detect overlaps with other unit's seenzones while they are moving (the area3D). The idea is we add a bit of complexity but keep performance strong and make detection more consistent from both sides.
@onready var shape_cast : ShapeCast3D = %ShapeCast3D

## Signal emitted when the [SeeingZone] successfully detects one or more [FriendlyUnit]s.
signal friendly_seen(friendlies : Array[FriendlyUnit])

## The enemy unit which owns this [SeeingZone], since only enemies need a typical vision cone at this point in development.
@export var enemy : EnemyUnit

# NOTE: Getting some instances of a unit coming around a corner and seeing another unit directly next to them when im not sure they should. See bug evidence 01. EnemyUnit has just seen FriendlyUnit despite no overlap in shapecast and hurtbox. EnemyUnit was coming through doorway.

func check_detection() -> void:
	if !enemy.is_incapacitated():
		var spotted : Array[FriendlyUnit] = []
		shape_cast.force_shapecast_update()
		var collision_instances = shape_cast.collision_result
		var seen_zones = collision_instances.map(func(instance): return instance.collider).filter(func(collider): return collider is SeenZone and collider.unit is FriendlyUnit)
		for zone : SeenZone in seen_zones:
			# NOTE: We need a whole separate system for tracking known/unknown incapacitated units. For now we just ignore them
			if !zone.unit.is_incapacitated():
				var vis_score = 0
				for point : VisibilityPoint in zone.vision_targets:
					if get_line_of_sight(point.global_position, zone.unit):
						vis_score += 1
				DebugConsole.log("Enemy sees " + str(vis_score) + "/8 of friendly's vision points", 3)
				if vis_score > 2:
					spotted.append(zone.unit)
			else:
				enemy.awareness.known_bodies.add(zone.unit)
		if !spotted.is_empty():
			friendly_seen.emit(spotted)
			enemy.speak("Hey!")