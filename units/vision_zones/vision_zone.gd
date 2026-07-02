## An extension of the [Area3D] node, which monitors for detection of and by other [VisionZone]s.
## [br]It is extended by two interconnected classes: [SeeingZone] which can detect [SeenZone]s which enter it, and [SeenZone], which can be detected by [SeeingZone]s it overlaps.
@abstract class_name VisionZone
extends Area3D

## Casts a ray from the [global_position] of this [VisionZone] to a specific position in 3D space, and returns true if the ray's first intersect is with the expected target, indicating clear line of sight. Returns false otherwise.
func get_line_of_sight(target_position : Vector3, expected_target : Node3D) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(global_position, target_position)
	var collision = get_world_3d().direct_space_state.intersect_ray(ray)
	return collision and collision.collider == expected_target


## Determines whether this [VisionZone] is currently detecting or being detected by any other [VisionZone]s.
@abstract func check_detection() -> void