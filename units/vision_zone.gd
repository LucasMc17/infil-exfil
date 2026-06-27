@abstract class_name VisionZone
extends Area3D

func get_line_of_sight(target_position : Vector3, expected_target : Node3D) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(global_position, target_position)
	var collision = get_world_3d().direct_space_state.intersect_ray(ray)
	return collision and collision.collider == expected_target


@abstract func check_detection() -> void