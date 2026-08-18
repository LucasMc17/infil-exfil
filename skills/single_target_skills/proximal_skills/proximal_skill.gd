class_name ProximalSkill
extends TargetedSkill

func get_all_targets() -> void:
	var is_friendly = user is FriendlyUnit
	var result : Array[Unit]
	var adjacent_points = Level.current_level.nav_map.get_valid_adjacent_cells(user.board_position)
	for point in adjacent_points:
		var occupier = Level.current_level.nav_map.get_point_occupier(point)
		if occupier is Unit and (occupier is EnemyUnit if is_friendly else occupier is FriendlyUnit):
			result.append(occupier)
	potential_targets = _filter_targets(result)