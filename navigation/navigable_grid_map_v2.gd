@tool
class_name NavigableGridMapV2
extends GridMap

# TODO: With the addition of new cell types this needs a more robust solution for setting up the grid. Right now it basically checks if each cell can see viable neighbors and links them if so. That won't be good enough for long. Instead we need to see if the two cells "agree". IE, once can see the other AND vice versa. This could get a little expensive, but hopefully should be fine as we should only need to run this once at the beginning of the level.

# First idea: each tile type has a function for getting it's viable neighbors. We run this, then for each viable neighbor, we also call its viable neighbor function. if it includes the original cell, we build the link. Then move onto next cell. UPSIDE: probably the most simple solution. DOWNSIDE: we'd end up calling that get viable neighbors fun a lot. a lot alot.

# Second idea: building on the above, we iterate through the grid, creating a GridPoint for each as we do, but also creating a property on GridPoint called viable neighbors. as we create the points, we do no actual comparisons yet. Just log them. Then we iterate a second time, this time for each cell we look at all its neighbors and for each one check: Are they already connected? If not, does the neighbor also include the original point in its neighbor dict too? If yes, connect them. This requires two iterations, and is still probably hefty, but I think probably bettter. To work.

const FLOOR := preload("./tiles/floor.tres")
const WALL := preload("./tiles/wall.tres")
const LADDER := preload("./tiles/ladder.tres")
const ALARM := preload("./tiles/alarm.tres")

const TILE_PALETTE : Array[Tile] = [FLOOR, WALL, LADDER, ALARM]

class GridPoint:
	var mesh_id : int
	var a_star_point : int
	var basis : Basis
	var position : Vector3i
	var tile : Tile
	var viable_connections : Dictionary[Vector3i, bool]

	var mesh_name : String:
		get():
			return TILE_PALETTE[mesh_id].name

	func _init(p_position: Vector3i, p_mesh_id : int, p_a_star_point : int, p_basis : Basis, p_tile : Tile):
		mesh_id = p_mesh_id
		a_star_point = p_a_star_point
		basis = p_basis
		position = p_position
		tile = p_tile
		viable_connections = tile.get_viable_connections(position, basis)

@export_category("Context")
@export var level : BaseLevel

@export_category("In Editor Debug")
## The start path [GridMap] position for in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var debug_start_cell: Vector3i:
	set(val):
		debug_start_cell = val
		do_debug_path(debug_start_cell, debug_end_cell)
## The end path [GridMap] position for in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var debug_end_cell: Vector3i:
	set(val):
		debug_end_cell = val
		do_debug_path(debug_start_cell, debug_end_cell)
## Enable/disable in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var show_debug: bool = true

## The [AStar3D] instance that can be used in your games.
var astar := CustomAStar.new()
## Dictionary of all points identified by their Vector3i coords in the [GridMap].
var point_map_by_grid_coords : Dictionary[Vector3i, GridPoint] = {}
var point_map_by_astar_ids: Dictionary[int, GridPoint] = {}
## A reuseable variable for loops. Can ignore.
var points : PackedVector3Array
## A dictionary of alarms in the level.
var alarms : Dictionary[Vector3i, bool] = {}

# TODO: Find a way to make that y height a magic number.
## Takes in a global position and converts it to it's nearest position on the grid (ASSUMES A Y HEIGHT OF 4)
static func convert_global_to_grid_position(pos : Vector3) -> Vector3:
	var result = pos.round()
	result.y = (result.y - (int(result.y) % 4)) / 4
	return result


## Takes in a grid local position and converts it to it's equivalent global position (ASSUMES A Y HEIGHT OF 4)[br]
## If [should_center] is true, it will add 0.5 to the x and z axis so that the resulting global position is centered on the grid tile.
static func convert_grid_to_global_position(pos : Vector3, should_center := false) -> Vector3:
	var result = Vector3(pos)
	result.y *= 4
	if should_center:
		result.x += 0.5
		result.z += 0.5
	return result


func _ready() -> void:
	if Engine.is_editor_hint():
		setup_astar_grid()


func _map_new_point(cell_pos : Vector3i, mesh_id : int, a_star_point : int, basis : Basis, tile : Tile):
	var point := GridPoint.new(cell_pos, mesh_id, a_star_point, basis, tile)

	if tile == LADDER:
		print(point.viable_connections)
	point_map_by_grid_coords[cell_pos] = point
	point_map_by_astar_ids[a_star_point] = point


func setup_astar_grid():
	var start_time = Time.get_ticks_msec()
	astar.clear()
	point_map_by_grid_coords.clear()
	point_map_by_astar_ids.clear()

	for item_id: int in range(TILE_PALETTE.size()):
		var tile : Tile = TILE_PALETTE[item_id]
		for cell_pos: Vector3i in get_used_cells_by_item(item_id):
			var orientation := get_cell_item_orientation(cell_pos)
			if tile == LADDER:
				DebugConsole.log(orientation)
			var basis = get_basis_with_orthogonal_index(orientation).inverse()
			var point_id: int = astar.get_available_point_id()
			astar.add_point(point_id, cell_pos)
			_map_new_point(cell_pos, item_id, point_id, basis, tile)
			if tile == ALARM:
				alarms[cell_pos] = true
	
	# Connect neighboring points
	for coord : Vector3i in point_map_by_grid_coords:
		var point = point_map_by_grid_coords[coord]
		for neighbor : Vector3i in point.viable_connections:
			if point_map_by_grid_coords.has(neighbor):
				var neighbor_point : GridPoint = point_map_by_grid_coords[neighbor]
				if point.viable_connections[neighbor] == false or (!astar.are_points_connected(point.a_star_point, neighbor_point.a_star_point) \
				and neighbor_point.viable_connections.has(coord)):
					astar.connect_points(point.a_star_point, neighbor_point.a_star_point)
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to build A* map: " + str(end_time - start_time) + " milliseconds", 3)


func find_path(start: Vector3i, end: Vector3i) -> Array:
	# Ensure start and end are within the grid and walkable
	if not point_map_by_grid_coords.has(start) or not point_map_by_grid_coords.has(end):
		return [] # No valid path
	
	var start_id: int = point_map_by_grid_coords[start].a_star_point
	var end_id: int = point_map_by_grid_coords[end].a_star_point
	
	# Get the path as an array of Vector3 points
	var path = astar.get_point_path(start_id, end_id)
	return path


func do_debug_path(start_pos : Vector3i, end_pos : Vector3i):
	# DebugDraw2D.clear_all()
	DebugDraw3D.clear_all()
	if !show_debug: return

	var path = find_path(start_pos, end_pos)
	if astar.get_point_count() == 0: return
	
	# DebugDraw2D.set_text.call_deferred("1. Grid count: ", astar.get_point_count(), 0, Color(0, 0, 0, 0), INF)
	# DebugDraw2D.set_text.call_deferred("2. Walkable Ids: ", NAVIGABLE_INDEXES, 0, Color(0, 0, 0, 0), INF)
	# if path.size() < 1:
	# 	DebugDraw2D.set_text.call_deferred("3. Path length: ", "No path found", 0, Color(0, 0, 0, 0), INF)
	# else:
	# 	DebugDraw2D.set_text.call_deferred("3. Path length: ", path.size(), 0, Color(0, 0, 0, 0), INF)
	# DebugDraw2D.set_text.call_deferred("4. Start Grid position / Start World position: ", str(start_pos, " / ", map_to_local(start_pos)), 0, Color.GREEN, INF)
	# DebugDraw2D.set_text.call_deferred("5. End Grid position / End World position: ", str(end_pos, " / ", map_to_local(end_pos)), 0, Color.RED, INF)
	
	var i: int = 0
	points.resize(path.size())
	
	var temp: Vector3 = map_to_local(start_pos)
	temp.y += 1
	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(1, 1, 1), Color.GREEN, true, INF)
	temp = map_to_local(end_pos)
	temp.y += 1
	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(1, 1, 1), Color.RED, true, INF)
	
	# Draw boxes: Green = start, Red = end, Yellow = all others
	for next_point: Vector3 in path:
		points[i] = map_to_local(next_point)
		points[i].y += 1 # move debug the box up
		if i > 0 and i < path.size() - 1: 
			DebugDraw3D.draw_box.call_deferred(points[i], Quaternion.IDENTITY, Vector3(1, 1, 1), Color.YELLOW, true, INF)
		i += 1

	# draw point path for added effect
	DebugDraw3D.draw_point_path.call_deferred(points, 0, 0.25, Color(0, 0, 0, 0), Color(0, 0, 0, 0), INF)


func paint_grid_square(position: Vector3, color : Color):
	var temp = position
	temp.y += 1
	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(0.9, 0.9, 0.9), color, true, INF)


func get_all_valid_moves(position: Vector3, max_moves : int) -> Array[Vector3]:
	var start_time = Time.get_ticks_msec()
	# paint_grid_square(map_to_local(position), Color.RED)
	var true_max_moves = max_moves * 2
	var potential_moves : Array[Vector3]
	var final_moves : Array[Vector3]
	for x in range(-true_max_moves, true_max_moves + 1):
		for y in range(-true_max_moves, true_max_moves + 1):
			for z in range(-true_max_moves, true_max_moves + 1):
				var vector = Vector3(x, y, z)
				if vector != Vector3.ZERO and point_map_by_grid_coords.has(vector + position) and !level.occupied_map.has(vector + position) and absi(x) + absi(y) + absi(z) <= true_max_moves :
					potential_moves.append(vector + position)
	
	for move in potential_moves:
		var path = find_path(position, move)
		if !path.is_empty() and path.size() - 1 <= max_moves:
			final_moves.append(move)
			# paint_grid_square(map_to_local(move), Color.GREEN)
	
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to find all valid moves: " + str(end_time - start_time) + " milliseconds", 3)
	return final_moves


func get_all_valid_moves_v2(position: Vector3i, max_moves: int):
	var valid_moves : Array[GridPoint] = []
	var point = point_map_by_grid_coords[position]
	_recusively_get_valid_pos(point, max_moves, valid_moves, true)
	for move in valid_moves:
		paint_grid_square(map_to_local(move.position), Color.GREEN)

func _recusively_get_valid_pos(point: GridPoint, moves_left: int, potential_moves : Array[GridPoint], top_level : bool, starting_point: GridPoint = null):
	# NOTE: serious performance issues here. 10 moves is enough to crash engine. The check below this comment used to be before the recursive function call (except the top level part). but this lead to missed moves, because it was possible to take a twisting path to a point, and end up with 0 moves left even though the move was not an extermity. This blocked it from checking its connections, ever.
	# Maybe a new map of cells which have had theri connections checked?
	if !top_level && point != starting_point && !potential_moves.has(point):
		potential_moves.append(point)
	else:
		starting_point = point
	if !moves_left == 0:
		var connections := astar.get_point_connections(point.a_star_point)
		for a_star_id : int in connections:
			var next_point : GridPoint = point_map_by_astar_ids[a_star_id]
			_recusively_get_valid_pos(next_point, moves_left - 1, potential_moves, false, starting_point)
	# if position != Vector3i.ZERO && !potential_moves.has(position):
	# 	potential_moves.append(position)
	# var point : GridPoint = point_map_by_grid_coords[position]
	# var connections = astar.get_point_connections(point.a_star_point)
	# if moves_left > 0:
	# 	for astar_point : int in connections:
	# 		_recusively_get_valid_pos(point_map_by_astar_ids[astar_point].position, moves_left - 1, potential_moves)
	# return potential_moves


func get_closest_point(pos : Vector3i, points_to_check : Array[Vector3i]) -> Variant:
	var result = null
	for point : Vector3i in points_to_check:
		var path = find_path(pos, point)
		if !result or path.size() < result.size():
			result = point
	return result