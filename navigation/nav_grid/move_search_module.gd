## Custom logic module for finding the complete list of moves a unit can make via recursion, and other related tasks.
class_name MoveSearchModule
extends Object

## The grid map which this module searches for visable moves within.
var grid_map : NavigableGridMap

func _init(map : NavigableGridMap) -> void:
	grid_map = map


## Utilizes recursion to find all valid moves from a valid position, assuming a certain max movement distance. The recursion makes it considerably faster than using the old, naive function for the same purpose. # 2
func get_all_valid_moves(grid_position: Vector3i, max_moves: int) -> Array[Vector3i]:
	var start_time = Time.get_ticks_msec()
	grid_map.space_blocking.resolve_blocks()
	var valid_moves : Dictionary[Vector3i, bool] = {}
	_recursively_get_valid_pos([grid_position], max_moves, valid_moves, grid_position)
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to find all valid moves with RECURSION: " + str(end_time - start_time) + " milliseconds", 4)
	return valid_moves.keys()


# NOTE: Long term, might want to pass in de-prioritized moves in addition to hard banned ones.
## Iterates throughout the unit's available moves, similarly to [get_all_valid_moves], but runs a passed callable on each position, returning the first one to return true. Starts from the unit's position and moves outward, so that the nearest viable position will always be chosen. Can optionally take a list of banned positions which will not be accepted as valid. Returns null if no valid move exists.[br]
## For use by AI-controlled units.  # 2
func probe_for_viable_move(grid_position : Vector3i, max_moves : int, callback : Callable, banned_moves : PackedVector3Array = []) -> Variant:
	# NOTE: This code could be cleaned up a bit. a lot of it is also reused from the get all valid moves func, but I am not sure if that can be avoided.
	var visited_points : Dictionary[Vector3i, bool]
	var moves_left := max_moves
	var last_point_ring : Array[Vector3i] = [grid_position]
	var start_time = Time.get_ticks_msec()
	var end_time : int
	grid_map.space_blocking.resolve_blocks()
	while moves_left > 0:
		var next_point_ring : Dictionary[Vector3i, bool] = {}
		for point : Vector3i in last_point_ring:
			var grid_point = grid_map.point_map_by_grid_coords[point]
			for connection : Vector3i in grid_point.connections:
				if connection != grid_position and !visited_points.has(connection) and !grid_map.point_map_by_grid_coords[connection].occupier:
					if !banned_moves.has(connection) and callback.call(connection):
						end_time = Time.get_ticks_msec()
						DebugConsole.log("Execution time to probe for a valid move WITH result: " + str(end_time - start_time) + " milliseconds")
						DebugConsole.log(visited_points.size())
						return connection
					else:
						next_point_ring[connection] = true
						visited_points[connection] = true
		moves_left -= 1
		last_point_ring = next_point_ring.keys()
		next_point_ring.clear()

	end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to probe for a valid move WITHOUT result: " + str(end_time - start_time) + " milliseconds")
	return null


## Returns an array of all the cells adjacent to the starting position which are actually connected to it. Useful for getting targets for proximal skills. # 2
func get_valid_adjacent_cells(point_position : Vector3i) -> Array[Vector3i]:
	var grid_point = grid_map.point_map_by_grid_coords[point_position]
	var result : Array[Vector3i]
	for potential_connection in [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]:
		var real_position = point_position + potential_connection
		if grid_point.connections.has(real_position):
			result.append(real_position)
	return result


## Utility function handling the recursion necessary to find all valid moves.
func _recursively_get_valid_pos(last_point_ring: Array[Vector3i], moves_left: int, potential_moves : Dictionary[Vector3i, bool], starting_point : Vector3i) -> void:
	var next_point_ring : Dictionary[Vector3i, bool] = {}
	for point : Vector3i in last_point_ring:
		if point != starting_point:
			potential_moves[point] = true
		var grid_point = grid_map.point_map_by_grid_coords[point]
		for connection : Vector3i in grid_point.connections:
			if connection != starting_point and !potential_moves.has(connection) and !grid_map.get_point_occupier(connection):
			# if connection != starting_point and !potential_moves.has(connection):
				next_point_ring[connection] = true
	
	if moves_left > 0 and next_point_ring.size() > 0:
		_recursively_get_valid_pos(next_point_ring.keys(), moves_left - 1, potential_moves, starting_point)