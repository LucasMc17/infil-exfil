@tool
## An extended [GridMap] designed to create a navigable map for A* to work with at first load.
@icon("uid://bqon7kxufra4h")
class_name NavigableGridMap
extends GridMap

# TODO: This file is getting really chunky. Should break it out to its own submodules to let it breathe a bit. I think the code around path blocking (units and unstable connections) could benefit a lot and get a lot cleaner.
# UNIT BLOCKING 1
# ALL POSSIBLE MOVES 2

## The size of the basic cell in the gridmap, as a Vector3.
static var CELL_SIZE := Vector3i(1, 4, 1)

# NOTE: I am allowing these preloads for now.
## Floor [Tile] resource.
const FLOOR := preload("uid://ct7pd1lj65vgj")
## Wall [Tile] resource.
const WALL := preload("uid://dp7k0jhnf8m4j")
## Ladder [Tile] resource.
const LADDER := preload("uid://btv5bvtvjfvyg")
## Alarm [Tile] resource.
const ALARM := preload("uid://b73x4ovcpyxvf")
## Corner [Tile] resource.
const CORNER := preload("uid://doewqvdgdbi2c")
## Dead End [Tile] resource.
const DEAD_END := preload("uid://bmon5owcn2cyp")
## Passage [Tile] resource.
const PASSAGE := preload("uid://dnxq50dy3lyem")
## Array of all preloaded [Tile] resources, in the order of their corresponding meshes within the [MeshLibrary] of the [GridMap].
const TILE_PALETTE : Array[Tile] = [FLOOR, WALL, LADDER, ALARM, CORNER, DEAD_END, PASSAGE]

@export_group("Context")
## The level this NavGrid lives inside of.
@export var level : Level

@export_group("In Editor Debug")
## The start path [GridMap] position for in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var debug_start_cell: Vector3i:
	set(val):
		debug_start_cell = val
		_draw_debug_path(debug_start_cell, debug_end_cell)
## The end path [GridMap] position for in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var debug_end_cell: Vector3i:
	set(val):
		debug_end_cell = val
		_draw_debug_path(debug_start_cell, debug_end_cell)
## Enable/disable in editor debugging.[br][br]
## This is only used in the editor to debug pathfinding.
@export var show_debug: bool = true

## The [AStar3D] instance that can be used in your games.
var astar := CustomAStar.new()
## Dictionary of all points identified by their Vector3i coords in the [GridMap].
var point_map_by_grid_coords : Dictionary[Vector3i, GridPoint] = {}
## Dictionary of all points identified by their A* IDs.
var point_map_by_astar_ids: Dictionary[int, GridPoint] = {}
## Module for handling blocked spaces in the navigable grid map.
var space_blocking := SpaceBlockingModule.new(self)
## Module for handling recursive searches for viable moves for units.
var move_searching := MoveSearchModule.new(self)

## A reuseable variable for loops. Can ignore.
var points : PackedVector3Array
## A dictionary of alarm_map in the level.
var alarm_map : Dictionary[Vector3i, bool] = {}
## A dictionary of all tiles which cannot be navigated while holding a hostage or otherwise while encumbered.
var ladder_map : Dictionary[Vector3i, GridPoint] = {}

## Takes in a global position and converts it to it's nearest position on the grid.
static func convert_global_to_grid_position(pos : Vector3i) -> Vector3:
	@warning_ignore("integer_division")
	return pos / CELL_SIZE


## Takes in a grid local position and converts it to it's equivalent global position.[br]
## If [should_center] is true, it will add 0.5 to the x and z axis so that the resulting global position is centered on the grid tile.
static func convert_grid_to_global_position(pos : Vector3i) -> Vector3:
	var result = pos * CELL_SIZE
	return result


func _ready() -> void:
	cell_size = CELL_SIZE
	if Engine.is_editor_hint():
		setup_astar_grid()


## Utility function for adding a new point to both the A* grid, and the coords grid.
func _map_new_point(cell_pos : Vector3i, mesh_id : int, a_star_point : int, tile_basis : Basis, tile : Tile) -> GridPoint:
	var point := GridPoint.new(self, cell_pos, mesh_id, a_star_point, tile_basis, tile)

	point_map_by_grid_coords[cell_pos] = point
	point_map_by_astar_ids[a_star_point] = point
	return point


## Utility function to connect a point to it's tile's viable neighbors.
func _connect_point_to_neighbors(point : GridPoint) -> void:
	for neighbor : Vector3i in point.potential_connections:
			if point_map_by_grid_coords.has(neighbor):
				var neighbor_point : GridPoint = point_map_by_grid_coords[neighbor]
				if point.potential_connections[neighbor] == false or (!astar.are_points_connected(neighbor_point.a_star_point, point.a_star_point, false) \
				and neighbor_point.potential_connections.has(point.position)):
					astar.connect_points(point.a_star_point, neighbor_point.a_star_point)


## Disable a point arbitrarily in the nav map by its coordinates. Note that this technically does not remove the point from navigation, but heavily discourages it by setting a high weight scale. This means the unit will prefer other paths to the one that takes it through this point, unless those other paths are 10+ points longer.
func disable_point(point_position : Vector3i) -> void:
	var point = point_map_by_grid_coords[point_position].a_star_point
	astar.set_point_weight_scale(point, 10.0)


## Enable a point arbitrarily in the nav map by its coordinates. This works by resetting the weight scale for this point to 1, so that it will be treated as being as viable a path as any other unoccupied tile.
func enable_point(point_position : Vector3i) -> void:
	var point = point_map_by_grid_coords[point_position].a_star_point
	astar.set_point_weight_scale(point, 1.0)


## Function for drawing viable paths in the editor, for testing.
func _draw_debug_path(start_pos : Vector3i, end_pos : Vector3i):
	DebugDraw3D.clear_all()
	if !show_debug: return

	var path = find_path(start_pos, end_pos)
	if astar.get_point_count() == 0: return
	
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
			var grid_point = _map_new_point(cell_pos, item_id, point_id, tile_basis, tile)
			if tile == LADDER:
				ladder_map[cell_pos] = grid_point
			elif tile == ALARM:
				alarm_map[cell_pos] = true
	
	# Connect neighboring points
	for coord : Vector3i in point_map_by_grid_coords:
		var point = point_map_by_grid_coords[coord]

		_connect_point_to_neighbors(point)
		
	var end_time = Time.get_ticks_msec()
	DebugConsole.log("Execution time to build A* map: " + str(end_time - start_time) + " milliseconds", 4)


## Returns an array of Vector3s, beginning with the [start] position and ending with the [end] position, which describes a navigable path between those two points. If no valid path exists, returns an empty array. The optional exact_point parameter determines whether or not the unit can path to point close to the intended point, if it is inaccessible due to being occupied. The point_radius parameter determines how wide of a radius around the point that unit must have to be withing to satisfy the move conditions without reaching the exact point. # 3
func find_path(start: Vector3i, end: Vector3i, exact_point := true, point_radius := 3) -> PackedVector3Array:
	# Ensure start and end are within the grid
	if not point_map_by_grid_coords.has(start) or not point_map_by_grid_coords.has(end):
		return [] # No valid path
	
	var start_id: int = point_map_by_grid_coords[start].a_star_point
	var end_id: int = point_map_by_grid_coords[end].a_star_point
	
	# Get the path as an array of Vector3 points and slice off the first point (the staring position)
	var path = astar.get_point_path(start_id, end_id)
	if !path.is_empty():
		path = path.slice(1)
	else:
		return []

	if !exact_point:
		var trimmed_path = path
		for i in range(point_radius):
			if trimmed_path.is_empty():
				return path
			var last_point = Vector3i(trimmed_path[-1])
			var grid_point = point_map_by_grid_coords[last_point]
			if !grid_point.occupier:
				return trimmed_path
			else:
				trimmed_path = trimmed_path.slice(0, -1)

	return path
	

## Takes in a starting position and an array of positions to check, and returns the position from the array which can be reached from the starting position with the shortest navigable path. If no position is found to be reachable, returns null. # 3
func get_closest_point(pos : Vector3i, points_to_check : Array[Vector3i]) -> Variant:
	# NOTE: In a future version this might also return the path to avoid recalculating it. This will require a bit of reworking for the enemy [move] func which expects only a final point and then calculates its own path.
	var result = null
	var result_path = null
	for point : Vector3i in points_to_check:
		var path = find_path(pos, point)
		if !path.is_empty() and (!result or path.size() < result_path.size()):
			result = point
			result_path = path
	return result


## Debug function for highlighting a square in the grid.
func paint_grid_square(grid_position: Vector3, color : Color):
	var temp = grid_position
	temp.y += 1
	DebugDraw3D.draw_box.call_deferred(temp, Quaternion.IDENTITY, Vector3(0.9, 0.9, 0.9), color, true, INF)


## Returns the scene occupying a point, or Null if it is empty.
func get_point_occupier(point_position : Vector3i) -> Node3D:
	return point_map_by_grid_coords[point_position].occupier