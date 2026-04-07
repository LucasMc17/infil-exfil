@tool
class_name NavigableGridMapV2
extends GridMap

const MESH_MAP = ["Floor", "Wall", "Ladder"]

const NAVIGABLE_INDEXES = [0, 2]

class GridPoint:
	var mesh_id : int
	var a_star_point : int
	var forward_direction : Vector3i
	var mesh_name : String:
		get():
			return MESH_MAP[mesh_id]

	func _init(p_mesh_id : int, p_a_star_point : int, p_forward_direction : Vector3):
		mesh_id = p_mesh_id
		a_star_point = p_a_star_point
		forward_direction = p_forward_direction


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
var astar := AStar3D.new()
## Dictionary of all points identified by their Vector3i coords in the [GridMap].
var point_map_by_grid_coords : Dictionary[Vector3i, GridPoint] = {}
## A reuseable variable for loops.  Can ignore.
var points : PackedVector3Array

func _ready() -> void:
	if Engine.is_editor_hint():
		setup_astar_grid()
		do_debug_path(debug_start_cell, debug_end_cell)


func _map_new_point(cell_pos : Vector3i, mesh_id : int, a_star_point : int, forward_direction : Vector3):
	var point := GridPoint.new(mesh_id, a_star_point, forward_direction)

	point_map_by_grid_coords[cell_pos] = point


func setup_astar_grid():
	# Clear previous A* data
	astar.clear()
	point_map_by_grid_coords.clear()
	
	# For all walkable tiles in grid map
	for item_id: int in NAVIGABLE_INDEXES:
		# Iterate through the grid to find walkable cells
		for cell_pos: Vector3i in get_used_cells_by_item(item_id):
			var orientation := get_cell_item_orientation(cell_pos)
			var basis = get_basis_with_orthogonal_index(orientation)
			var forward_direction = -basis.z
			var point_id: int = astar.get_available_point_id()
			astar.add_point(point_id, cell_pos)
			_map_new_point(cell_pos, item_id, point_id, forward_direction as Vector3)
	
	# Connect neighboring points
	for coord : Vector3i in point_map_by_grid_coords:
		var point = point_map_by_grid_coords[coord]
		var neighbors : Array[Vector3i]
		if point.mesh_id == 0:
			neighbors = [
				Vector3(coord.x + 1, coord.y, coord.z),
				Vector3(coord.x - 1, coord.y, coord.z),
				Vector3(coord.x, coord.y, coord.z + 1),
				Vector3(coord.x, coord.y, coord.z - 1)
			]
			for neighbor_pos in neighbors:
				var neighbor_cell: Vector3i = Vector3i(neighbor_pos.x, neighbor_pos.y, neighbor_pos.z)
				if point_map_by_grid_coords.has(neighbor_cell) and point_map_by_grid_coords[neighbor_cell].mesh_id == 0:
					var neighbor_id: int = point_map_by_grid_coords[neighbor_cell].a_star_point
					if not astar.are_points_connected(point.a_star_point, neighbor_id):
						astar.connect_points(point.a_star_point, neighbor_id)
		elif point.mesh_id == 2:
			# print(point.forward_direction)
			neighbors = [
				coord + point.forward_direction + Vector3i(0, 1, 0),
				coord + point.forward_direction * -1,
				coord + Vector3i((Vector3(point.forward_direction).rotated(Vector3.UP, deg_to_rad(90)))),
				coord + Vector3i((Vector3(point.forward_direction).rotated(Vector3.UP, deg_to_rad(-90)))),
			]
			print(neighbors)
		
			# Only connect neighnors that are navigable, and only connect them once
			for neighbor_pos in neighbors:
				var neighbor_cell: Vector3i = Vector3i(neighbor_pos.x, neighbor_pos.y, neighbor_pos.z)
				if point_map_by_grid_coords.has(neighbor_cell):
					var neighbor_id: int = point_map_by_grid_coords[neighbor_cell].a_star_point
					if not astar.are_points_connected(point.a_star_point, neighbor_id):
						astar.connect_points(point.a_star_point, neighbor_id)


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
	
	DebugDraw2D.set_text.call_deferred("1. Grid count: ", astar.get_point_count(), 0, Color(0, 0, 0, 0), INF)
	DebugDraw2D.set_text.call_deferred("2. Walkable Ids: ", NAVIGABLE_INDEXES, 0, Color(0, 0, 0, 0), INF)
	if path.size() < 1:
		DebugDraw2D.set_text.call_deferred("3. Path length: ", "No path found", 0, Color(0, 0, 0, 0), INF)
	else:
		DebugDraw2D.set_text.call_deferred("3. Path length: ", path.size(), 0, Color(0, 0, 0, 0), INF)
	DebugDraw2D.set_text.call_deferred("4. Start Grid position / Start World position: ", str(start_pos, " / ", map_to_local(start_pos)), 0, Color.GREEN, INF)
	DebugDraw2D.set_text.call_deferred("5. End Grid position / End World position: ", str(end_pos, " / ", map_to_local(end_pos)), 0, Color.RED, INF)
	
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
	