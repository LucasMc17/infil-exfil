class_name CustomAStar
extends AStar3D

var last_position

# TODO: more to be done here. Would like to write a heuristic which penalizes turning, so that units prioritize walking in a straight line over zig zagging.
# This might be done via referenceing [World.level.active_unit] but not sure yet best, most efficient way since these functions are called a lot.
func _compute_cost(from_id, to_id):
	# Manhattan heuristic
	var u_pos = get_point_position(from_id)
	var v_pos = get_point_position(to_id)
	return abs(u_pos.x - v_pos.x) + abs(u_pos.y - v_pos.y) + abs(u_pos.z - v_pos.z)


func _estimate_cost(from_id, to_id):
	# Manhattan heuristic
	var u_pos = get_point_position(from_id)
	var v_pos = get_point_position(to_id)
	return abs(u_pos.x - v_pos.x) + abs(u_pos.y - v_pos.y) + abs(u_pos.z - v_pos.z)