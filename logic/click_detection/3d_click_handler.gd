## Node3D extended to handle clicks in 3D space, and return the clicked object and it's position.
class_name ClickHandler3D
extends Node3D

## Determines the clicked position in 3D space, and returns either a Dictionary of information about the clicked object, or null if no object was clicked.
func get_clicked_object() -> Variant:
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()

	# Project a ray from the camera through the mouse position
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000

	var ray_params = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var result = get_world_3d().direct_space_state.intersect_ray(ray_params)

	if result.is_empty():
		return null # Nothing clicked
	
	return result
