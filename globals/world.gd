extends Node

var level : BaseLevel

# func get_line_of_site(seer : Vector3, end_position : Vector3) -> bool:
# 	var ray := PhysicsRayQueryParameters3D.create(start_position, end_position)
# 	var collision = get_world_3d().direct_space_state.intersect_ray(ray)
# 	if collision and collision.collider == zone.friendly:
# 		vis_score += 1