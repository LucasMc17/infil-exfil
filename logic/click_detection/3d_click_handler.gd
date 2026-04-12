class_name ClickHandler3D extends Node3D

func get_clicked_object() -> Variant:
	print('click detection')
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()

	# Project a ray from the camera through the mouse position
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000

	var ray_params = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var result = get_world_3d().direct_space_state.intersect_ray(ray_params)

	if result.is_empty():
		return null # Nothing clicked
	
	# Get the global position of the collision
	return result
	# var hit_pos = result.position
	# Convert global world position to GridMap local coordinates
	# return local_to_map(to_local(hit_pos))
