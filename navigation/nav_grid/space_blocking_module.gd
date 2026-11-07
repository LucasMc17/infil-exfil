## Logic module for handling the blocking of spaces on a [NavigableGridMap].
class_name SpaceBlockingModule
extends Object

## The grid map this blocking module effects.
var grid_map : NavigableGridMap
## A dictionary tracking the positions of all tile blocking scenes in the level.
var occupation_map : Dictionary[int, GridPoint] = {}

func _init(map : NavigableGridMap) -> void:
	grid_map = map


## Main function for determining which points and connections between points are navigable to the active unit. Works in two phases, first by severing connections between tiles which the active unit is not able to perform (such as ladders when carrying a body), and then by completely blocking off spaces which are occupied by other units. # 1
func resolve_blocks() -> void:
	_resolve_unstable_connections()
	_resolve_occupied_spaces()


## Utility function to break the connection between a point and it's unstable neighbors. # 1
func _sever_unstable_connections(point : GridPoint) -> void:
	for connection in point.unstable_connected_points:
		grid_map.astar.disconnect_points(point.a_star_point, connection)


## Utility function to rebuild unstable connections between points. # 1
func _rebuild_unstable_connections(point : GridPoint) -> void:
	for connection in point.unstable_connected_points:
		if !grid_map.astar.are_points_connected(point.a_star_point, connection):
			grid_map.astar.connect_points(point.a_star_point, connection)	


## Utility function which severs all complicated tile connections if the active unit is encumbered and unable to traverse them. # 1
func _resolve_unstable_connections() -> void:
	if Unit.active_unit.is_encumbered:
		for point : GridPoint in grid_map.ladder_map.values():
			_sever_unstable_connections(point)
	else:
		for point : GridPoint in grid_map.ladder_map.values():
			_rebuild_unstable_connections(point)


## Utility function which iterates through the list of point-blocking scenes and marks their positions as un-navigable, so that units may block each other's paths. # 1
func _resolve_occupied_spaces() -> void:
	# TODO: When scenes other than Units are able to block spaces, this will change.
	var previously_occupied : Array[GridPoint]
	var newly_occupied : Array[GridPoint]

	# First pass: clear old positions of occupiers and get list of those old positions.
	for unit : Unit in Level.current.all_units:
		var unit_id := unit.get_instance_id()
		if occupation_map.has(unit_id):
			var old_point = occupation_map[unit_id]
			previously_occupied.append(old_point)
			old_point.occupier = null

	# Second pass: assign occupiers to new positions, get list of those new positions
	for unit : Unit in Level.current.all_units:
		var unit_id := unit.get_instance_id()
		if grid_map.point_map_by_grid_coords.has(unit.board_position):
			var new_point = grid_map.point_map_by_grid_coords[unit.board_position]
			if _should_block_unit_space(unit):
				newly_occupied.append(new_point)
			occupation_map[unit_id] = new_point
			if !unit.is_incapacitated():
				new_point.occupier = unit

	# Finally, re enable the old points and disable the new ones.		
	for point : GridPoint in previously_occupied:
		grid_map.enable_point(point.position)
	
	for point : GridPoint in newly_occupied:
		grid_map.disable_point(point.position)


## Helper function to determine if the currently active unit should consider another unit as actively blocking the space they are occupying. Logic is spelled out for easy refactoring in future iterations. # 1
func _should_block_unit_space(unit : Unit) -> bool:
	var active_unit = Unit.active_unit
	if active_unit == unit:
		return false
	if !grid_map.point_map_by_grid_coords.has(unit.board_position):
		return false
	if unit.is_incapacitated():
		return false
	if active_unit is not EnemyUnit:
		return true
	if unit is EnemyUnit:
		return true
	if !active_unit.awareness.friendly_knowledge.sightings.has(unit.get_instance_id()):
		return false
	return true