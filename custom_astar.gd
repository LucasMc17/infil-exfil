class_name CustomAStar
extends AStar3D

# This might be done via referenceing [World.level.active_unit] but not sure yet best, most efficient way since these functions are called a lot.
func _compute_cost(from_id: int, to_id: int) -> float:
	return _manhattan(from_id, to_id)


func _estimate_cost(from_id: int, to_id: int) -> float:
	return _manhattan(from_id, to_id)


## Applies the Manhattan Heuristic, meaning no diagonal movements. A tile catty corner to another, is 2 steps away, instead of considering it as being ~1.4 per regular Euclidean geometry.
func _manhattan(from_id: int, to_id: int) -> float:
	var u_pos = get_point_position(from_id)
	var v_pos = get_point_position(to_id)
	return abs(u_pos.x - v_pos.x) + abs(u_pos.y - v_pos.y) + abs(u_pos.z - v_pos.z)


## Prioritizes moving first along the Z-axis (Forward/Backward, or North/South), before along the X-axis (Left/Right, or East/West). Reduces turning but does so by enforcing an arbitary rule.
func _z_first(from_id: int, to_id: int) -> float:
	var u_pos3 : Vector3 = get_point_position(from_id)
	var v_pos3 : Vector3 = get_point_position(to_id)

	var u_pos2 := Vector2(u_pos3.x, u_pos3.z)
	var v_pos2 := Vector2(v_pos3.x, v_pos3.z)

	var diff = v_pos2 - u_pos2
	if diff.y != 0:
		return 1
	return 1.5


# NOTE: There's a theoretical solution here that would discourage turning, but it would require reworking my whole nav grid set up. Picture bundles of points for each tile instead of just one. Each point would indicate which direction the unit came to that tile from. It's theoretically possible, but it's a LOT of work for fixing the 10% of the way there that manhattan doesn't get us. Not sure if it's worth it.
