## 3D node responsible for marking paths for the player as they plan moves.
class_name PathMarkingSystem
extends Node3D

## Level context for path finding.
@export var level : BaseLevel

@onready var _planned_paths_holder := %PlannedPathsHolder
@onready var _hovered_path_holder := %HoveredPathHolder
@onready var _viable_move_holder := %ViableMoveHolder

## The cell highlight scene.
const HIGHLIGHT = preload("res://cell_highlight.tscn")
## Preloaded path marker sprite scene.
const PATH_MARKER := preload('res://navigation/path_marking/path_marker.tscn')
## Preloaded small path marker sprite scene.
const PATH_MARKER_SMALL := preload('res://navigation/path_marking/path_marker_small.tscn')

## The path the player has marked with planned points.
var planned_path : Array[PackedVector3Array] = []
## The path plotted to the point that the player is hovering their mouse over, either from the player's current position or the last point on the last array in the [planned_path].
var hovered_path : PackedVector3Array = []
## The highlighted, viable moves at a this moment.
var viable_moves : PackedVector3Array = []

## The currently considered path, including both what the player has planned with points and where their cursor is currently resting.
var path : PackedVector3Array:
	get():
		var result = []
		for subpath in planned_path:
			result.append_array(subpath)
		result.append_array(hovered_path)
		return result

## Mark the intended path for the player's benefit.
func mark_hovered_path(end_point : Vector3) -> void:
	clear_hovered_path()
	var starting_point : Vector3
	if !planned_path.is_empty():
		var last_subpath = planned_path[planned_path.size() - 1]
		starting_point = last_subpath[last_subpath.size() - 1]
	else:
		starting_point = level.active_unit.actual_position
	hovered_path = level.nav_map.find_path(starting_point, end_point).slice(1)
	for cell in hovered_path:
		var path_marker_scene = PATH_MARKER_SMALL.instantiate()
		path_marker_scene.position = NavigableGridMap.convert_grid_to_global_position(cell)
		_hovered_path_holder.add_child(path_marker_scene)


## Marks the full planned path, based on placed waypoints.
func mark_planned_path() -> void:
	for child in _planned_paths_holder.get_children():
		child.queue_free()
	for subpath in planned_path:
		for step in subpath:
			var path_marker_scene = PATH_MARKER.instantiate()
			path_marker_scene.position = NavigableGridMap.convert_grid_to_global_position(step)
			_planned_paths_holder.add_child(path_marker_scene)



## Clears the path_markers from the level scene.
func clear_hovered_path() -> void:
	hovered_path = []
	for child in _hovered_path_holder.get_children():
		child.queue_free()


## Fully clears the planned path.
func wipe_planned_path() -> void:
	clear_hovered_path()
	planned_path = []
	for child in _planned_paths_holder.get_children():
		child.queue_free()


## Places a routing waypoint for the path, enforcing that, if movement is confirmed, the player will first travel to this point along the indicated path.
func place_waymarker(point : Vector3) -> void:
	clear_hovered_path()
	var mp_cost = 0
	var starting_point : Vector3
	if !planned_path.is_empty():
		for subpath in planned_path:
			mp_cost += subpath.size()
		var last_subpath = planned_path[planned_path.size() - 1]
		starting_point = last_subpath[last_subpath.size() - 1]
	else:
		starting_point = level.active_unit.actual_position
	var subpath = level.nav_map.find_path(starting_point, point).slice(1)
	mp_cost += subpath.size()
	set_viable_moves(point, level.active_unit.movement_points - mp_cost)
	planned_path.append(subpath)
	mark_planned_path()


## Clears the board of highlighted, viable moves.
func clear_viable_moves() -> void:
	viable_moves = []
	for child in _viable_move_holder.get_children():
		child.queue_free()


## Sets and highlights the viable moves from a given position with a given maximum move distance.
func set_viable_moves(start_position : Vector3, distance : int) -> void:
	clear_viable_moves()
	viable_moves = level.nav_map.get_all_valid_moves(start_position, distance)
	for move in viable_moves:
		var highlight_scene = HIGHLIGHT.instantiate()
		_viable_move_holder.add_child(highlight_scene)
		highlight_scene.global_position = NavigableGridMap.convert_grid_to_global_position(move, true)