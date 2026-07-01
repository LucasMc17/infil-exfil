@tool
## An extended [GridMap] designed to create a navigable map for A* to work with at first load.
class_name NavigableGridMap
extends GridMap

## The size of the basic cell in the gridmap, as a Vector3.
static var CELL_SIZE := Vector3(1.0, 4.0, 1.0)

## Floor [Tile] resource.
const FLOOR := preload("./tiles/floor.tres")
## Wall [Tile] resource.
const WALL := preload("./tiles/wall.tres")
## Ladder [Tile] resource.
const LADDER := preload("./tiles/ladder.tres")
## Alarm [Tile] resource.
const ALARM := preload("./tiles/alarm.tres")
## Array of all preloaded [Tile] resources, in the order of their corresponding meshes within the [MeshLibrary] of the [GridMap].
const TILE_PALETTE : Array[Tile] = [FLOOR, WALL, LADDER, ALARM]

## Custom class representing a single point, both in the grid map and the A* grid. Contains information about that point's position, tile type, connections, mesh ID, rotation and A* ID. Designed to allow for easy referencing of specific spoints in the context of either the GridMap or the A* grid.
class GridPoint:
	## The ID of the mesh occupying this point in the GridMap.
	var mesh_id : int
	## The ID of this point in the A* nav grid.
	var a_star_point : int
	## The rotational basis of the point.
	var basis : Basis
	## The position of this point in the NavGrid.
	var position : Vector3i
	## The [Tile] type of this point.
	var tile : Tile
	## A dictionary representing the absolute positions of possible connections to this tile based on its type, without consideration of whether they are actually able to connect.
	var potential_connections : Dictionary[Vector3i, bool]
	## A dictionary representing the absolute positions of real connections for this point in the A* grid.
	var real_connections : Dictionary[Vector3i, bool]
	## The name of the mesh shown at this position in the GridMap.
	var mesh_name : String:
		get():
			return TILE_PALETTE[mesh_id].name

	func _init(p_position: Vector3i, p_mesh_id : int, p_a_star_point : int, p_basis : Basis, p_tile : Tile):
		mesh_id = p_mesh_id
		a_star_point = p_a_star_point
		basis = p_basis
		position = p_position
		tile = p_tile
		potential_connections = tile.get_viable_connections(position, basis)

@export_group("Context")
## The level this NavGrid lives inside of.
@export var level : BaseLevel

# @export_group("In Editor Debug")
## The start path [GridMap] position for in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
# @export var debug_start_cell: Vector3i:
# 	set(val):
# 		debug_start_cell = val
# 		do_debug_path(debug_start_cell, debug_end_cell)
# ## The end path [GridMap] position for in editor debugging.[br][br]
# ## This is only used in the editor to debug pathfinding.
# @export var debug_end_cell: Vector3i:
# 	set(val):
# 		debug_end_cell = val
# 		do_debug_path(debug_start_cell, debug_end_cell)
# ## Enable/disable in editor debugging.[br][br]
# ## This is only used in the editor to debug pathfinding.
# @export var show_debug: bool = true

## The [AStar3D] instance that can be used in your games.
var astar := CustomAStar.new()
## Dictionary of all points identified by their Vector3i coords in the [GridMap].
var point_map_by_grid_coords : Dictionary[Vector3i, GridPoint] = {}
## Dictionary of all points identified by their A* IDs.
var point_map_by_astar_ids: Dictionary[int, GridPoint] = {}
## A reuseable variable for loops. Can ignore.
var points : PackedVector3Array
## A dictionary of alarms in the level.
var alarms : Dictionary[Vector3i, bool] = {}
## A dictionary representing spaces temporarily blocked by Units standing on them.
var blocked_spaces : Dictionary[Vector3i, GridPoint] = {}

## Takes in a global position and converts it to it's nearest position on the grid.
static func convert_global_to_grid_position(pos : Vector3) -> Vector3:
	var result = pos.round()
	return result / CELL_SIZE


## Takes in a grid local position and converts it to it's equivalent global position.[br]
## If [should_center] is true, it will add 0.5 to the x and z axis so that the resulting global position is centered on the grid tile.
static func convert_grid_to_global_position(pos : Vector3, should_center := false) -> Vector3:
	var result = Vector3(pos) * CELL_SIZE
	if should_center:
		result.x += 0.5 * CELL_SIZE.x
		result.z += 0.5 * CELL_SIZE.z
	return result


func _ready() -> void:
	cell_size = CELL_SIZE
	if Engine.is_editor_hint():
		setup_astar_grid()


## Utility function for adding a new point to both the A* grid, and the coords grid.
func _map_new_point(cell_pos : Vector3i, mesh_id : int, a_star_point : int, tile_basis : Basis, tile : Tile) -> void:
	var point := GridPoint.new(cell_pos, mesh_id, a_star_point, tile_basis, tile)

	point_map_by_grid_coords[cell_pos] = point
	point_map_by_astar_ids[a_star_point] = point


## Utility function to connect a point to it's tile's viable neighbors.
func _connect_point_to_neighbors(point : GridPoint) -> void:
	for neighbor : Vector3i in point.potential_connections:
			if point_map_by_grid_coords.has(neighbor):
				var neighbor_point : GridPoint = point_map_by_grid_coords[neighbor]
				if point.potential_connections[neighbor] == false or (!astar.are_points_connected(neighbor_point.a_star_point, point.a_star_point, false) \
				and neighbor_point.potential_connections.has(point.position)):
					astar.connect_points(point.a_star_point, neighbor_point.a_star_point)
					point.real_connections[neighbor_point.position] = true
					neighbor_point.real_connections[point.position] = true


# NOTE: Not currently in use, but may still prove useful for changing nav grid without regenning whole grid. IE if a door locks.
## Utility function to break the connection between a point and it's neighbors.
func _disconnect_point_from_neighbors(point : GridPoint, two_way := true, ingoing := true) -> void:
	var connections = astar.get_point_connections(point.a_star_point)
	for connection in connections:
		if ingoing:
			astar.disconnect_points(connection, point.a_star_point, two_way)
		else:
			astar.disconnect_points(point.a_star_point, connection, two_way)


# NOTE: I'm still not completely in love with this solution but it works. I tried disabling one way connections to specific cells but it seemed to work really inconsistently.
## Utility function which takes in a list of units and marks their positions as un-navigable, so that units may block each other's paths.
func _update_block_spaces(units : Array[Unit], active_unit : Unit) -> void:
	var to_block = {}
	for unit : Unit in units:
		if unit != active_unit:
			to_block[unit.actual_position] = true
	for pos : Vector3i in blocked_spaces.keys():
		if !to_block.has(pos):
			var point = point_map_by_grid_coords[pos]
			astar.set_point_disabled(point.a_star_point, false)
			blocked_spaces.erase(pos)
	for pos : Vector3i in to_block.keys():
		if !blocked_spaces.has(pos):
			var point = point_map_by_grid_coords[pos]
			astar.set_point_disabled(point.a_star_point, true)
			blocked_spaces[pos] = point


## Utility function handling the recursion necessary to find all valid moves.
func _recursively_get_valid_pos(point: Vector3i, moves_left: int, potential_moves : Dictionary[Vector3i, bool], base_level : bool, starting_point : Vector3i) -> void:
	if !potential_moves.has(point) and point != starting_point:
		potential_moves[point] = true
	
	if moves_left == 0:
		return 

	if base_level:
		_update_block_spaces(World.level.units, World.level.active_unit)
	
	for connection: Vector3i in point_map_by_grid_coords[point].real_connections.keys():
		if !blocked_spaces.has(connection):
			_recursively_get_valid_pos(connection, moves_left - 1, potential_moves, false, starting_point)

	if base_level:
		return


## Initializes the nav grid by creating all A* points and defining navigable connections based on their potential connections. Should be called once when the level is loaded.
func setup_astar_grid() -> void:
	var start_time = Time.get_ticks_msec()
	astar.clear()
	point_map_by_grid_coords.clear()
	point_map_by_astar_ids.clear()

	for item_id: int in range(TILE_PALETTE.size()):
		var tile : Tile = TILE_PALETTE[item_id]
		for cell_pos: Vector3i in get_used_cells_by_item(item_id):
			var orientation := get_cell_item_orientation(cell_pos)
			var tile_basis = get_basis_with_orthogonal_index(orientation).inverse()
			var point_id: int = astar.get_available_point_id()
			astar.add_point(point_id, cell_pos)
			_map_new_point(cell_pos, item_id, point_id, tile_basis, tile)
			if tile == ALARM:
				alarms[cell_pos] = true
	
	# Connect neighboring points
	for coord : Vector3i in point_map_by_grid_coords:
		var point = point_map_by_grid_coords[coord]

		_connect_point_to_neighbors(point)
		
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to build A* map: " + str(end_time - start_time) + " milliseconds", 4)


## Returns an array of Vector3s, beginning with the [start] position and ending with the [end] position, which describes a navigable path between those two points. If no valid path exists, returns an empty array.
func find_path(start: Vector3i, end: Vector3i) -> Array:
	# Ensure start and end are within the grid and walkable
	if not point_map_by_grid_coords.has(start) or not point_map_by_grid_coords.has(end):
		return [] # No valid path
	
	var start_id: int = point_map_by_grid_coords[start].a_star_point
	var end_id: int = point_map_by_grid_coords[end].a_star_point
	
	# Get the path as an array of Vector3 points
	var path = astar.get_point_path(start_id, end_id)
	return path
	

## Takes in a starting position and an array of positions to check, and returns the position from the array which can be reached from the starting position with the shortest navigable path. If no position is found to be reachable, returns null.
func get_closest_point(pos : Vector3i, points_to_check : Array[Vector3i]) -> Variant:
	var result = null
	var result_path = null
	for point : Vector3i in points_to_check:
		var path = find_path(pos, point)
		if !result or path.size() < result_path.size():
			result = point
			result_path = path
	return result


# TODO: Return to this later, it's not working atm.
# func do_debug_path(start_pos : Vector3i, end_pos : Vector3i):
# 	# DebugDraw2D.clear_all()
# 	DebugDraw3D.clear_all()
# 	if !show_debug: return

# 	var path = find_path(start_pos, end_pos)
# 	if astar.get_point_count() == 0: return
	
# 	DebugDraw2D.set_text.call_deferred("1. Grid count: ", astar.get_point_count(), 0, Color(0, 0, 0, 0), INF)
# 	if path.size() < 1:
# 		DebugDraw2D.set_text.call_deferred("3. Path length: ", "No path found", 0, Color(0, 0, 0, 0), INF)
# 	else:
# 		DebugDraw2D.set_text.call_deferred("3. Path length: ", path.size(), 0, Color(0, 0, 0, 0), INF)
# 	DebugDraw2D.set_text.call_deferred("4. Start Grid position / Start World position: ", str(start_pos, " / ", map_to_local(start_pos)), 0, Color.GREEN, INF)
# 	DebugDraw2D.set_text.call_deferred("5. End Grid position / End World position: ", str(end_pos, " / ", map_to_local(end_pos)), 0, Color.RED, INF)
	
# 	var i: int = 0
# 	points.resize(path.size())
	
# 	var temp: Vector3 = map_to_local(start_pos)
# 	temp.y += 1
# 	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(1, 1, 1), Color.GREEN, true, INF)
# 	temp = map_to_local(end_pos)
# 	temp.y += 1
# 	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(1, 1, 1), Color.RED, true, INF)
	
# 	# Draw boxes: Green = start, Red = end, Yellow = all others
# 	for next_point: Vector3 in path:
# 		points[i] = map_to_local(next_point)
# 		points[i].y += 1 # move debug the box up
# 		if i > 0 and i < path.size() - 1: 
# 			DebugDraw3D.draw_box.call_deferred(points[i], Quaternion.IDENTITY, Vector3(1, 1, 1), Color.YELLOW, true, INF)
# 		i += 1

# 	# draw point path for added effect
# 	DebugDraw3D.draw_point_path.call_deferred(points, 0, 0.25, Color(0, 0, 0, 0), Color(0, 0, 0, 0), INF)


## Debug function for highlighting a square in the grid.
func paint_grid_square(tile_position: Vector3, color : Color):
	var temp = tile_position
	temp.y += 1
	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(0.9, 0.9, 0.9), color, true, INF)


## Utilizes recursion to find all valid moves from a valid position, assuming a certain max movement distance. The recursion makes it considerably faster than using the old, naive function for the same purpose.
func get_all_valid_moves(tile_position: Vector3i, max_moves: int) -> Array[Vector3i]:
	var start_time = Time.get_ticks_msec()
	var valid_moves : Dictionary[Vector3i, bool] = {}
	_recursively_get_valid_pos(tile_position, max_moves, valid_moves, true, tile_position)
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to find all valid moves with RECURSION: " + str(end_time - start_time) + " milliseconds", 4)
	return valid_moves.keys()


## DEPRECATED: Takes in a starting position and a maximum move distance and returns an array of all valid positions to move to from that position. Will be removed in future commits.
func get_all_valid_moves_OLD(tile_position: Vector3i, max_moves : int) -> Array[Vector3i]:
	_update_block_spaces(World.level.units, World.level.active_unit)
	var start_time = Time.get_ticks_msec()
	var true_max_moves = max_moves * 2
	var potential_moves : Array[Vector3i]
	var final_moves : Array[Vector3i]
	for x in range(-true_max_moves, true_max_moves + 1):
		for y in range(-true_max_moves, true_max_moves + 1):
			for z in range(-true_max_moves, true_max_moves + 1):
				var vector = Vector3i(x, y, z)
				if vector != Vector3i.ZERO and point_map_by_grid_coords.has(vector + tile_position) and absi(x) + absi(y) + absi(z) <= true_max_moves :
					potential_moves.append(vector + tile_position)
	
	for move in potential_moves:
		var path = find_path(tile_position, move)
		if !path.is_empty() and path.size() - 1 <= max_moves:
			final_moves.append(move)
	
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to find all valid moves: " + str(end_time - start_time) + " milliseconds", 4)
	return final_moves