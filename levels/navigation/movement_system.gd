## 3D node responsible for marking all viable moves to the player, as well as charting paths for the player as they plan moves.
class_name MovementSystem
extends Node3D

## Level context for path finding.
@export var level : Level

@onready var _planned_paths_holder := %PlannedPathsHolder
@onready var _hovered_path_holder := %HoveredPathHolder
@onready var _viable_move_holder := %ViableMoveHolder
@onready var _all_move_holder := %AllMoveHolder

## The cell highlight scene.
const HIGHLIGHT = preload("./cell_highlight.tscn")
## The cell unavailable highlight scene.
const UNAVAILABLE_HIGHLIGHT = preload("./cell_highlight_unavailable.tscn")
## Preloaded path marker sprite scene.
const PATH_MARKER := preload('./path_marker.tscn')
## Preloaded small path marker sprite scene.
const PATH_MARKER_SMALL := preload('./path_marker_small.tscn')

## The path the player has marked with planned points.
var planned_path : Array[PackedVector3Array] = []
## The path plotted to the point that the player is hovering their mouse over, either from the player's current position or the last point on the last array in the [planned_path].
var hovered_path : PackedVector3Array = []
## All theoretical moves the currently active unit can make. Those not also found in the [viable_moves] array will be grayed out to show their unavailability.
var all_unit_moves : PackedVector3Array = []
## The highlighted, viable moves at a this moment.
var viable_moves : PackedVector3Array = []
## The active unit in the level.
var active_unit : Unit

## The currently considered path, including both what the player has planned with points and where their cursor is currently resting.
var path : PackedVector3Array:
	get():
		var result = []
		for subpath in planned_path:
			result.append_array(subpath)
		result.append_array(hovered_path)
		return result

# PATH HOVERING

## Mark the intended path for the player's benefit.
func mark_hovered_path(end_point : Vector3) -> void:
	clear_hovered_path()
	var starting_point : Vector3
	if !planned_path.is_empty():
		var last_subpath = planned_path[planned_path.size() - 1]
		starting_point = last_subpath[last_subpath.size() - 1]
	else:
		starting_point = level.active_unit.board_position
	hovered_path = level.nav_map.find_path(starting_point, end_point).slice(1)
	for cell in hovered_path:
		var path_marker_scene = PATH_MARKER_SMALL.instantiate()
		path_marker_scene.position = NavigableGridMap.convert_grid_to_global_position(cell)
		_hovered_path_holder.add_child(path_marker_scene)


## Clears the path_markers for the hovered path from the level scene.
func clear_hovered_path() -> void:
	hovered_path = []
	for child in _hovered_path_holder.get_children():
		child.queue_free()

# PATH PLANNING

## Marks the full planned path, based on placed waypoints. A private function because it is only ever called when placing a waymarker which is done from within this script.
func _mark_planned_path() -> void:
	Events.waymarker_placed.emit()
	for child in _planned_paths_holder.get_children():
		child.queue_free()
	for subpath in planned_path:
		for step in subpath:
			var path_marker_scene = PATH_MARKER.instantiate()
			path_marker_scene.position = NavigableGridMap.convert_grid_to_global_position(step)
			_planned_paths_holder.add_child(path_marker_scene)


## Fully clears the planned path, and removes it's waymarkers from the level scene.
func wipe_planned_path() -> void:
	Events.planned_path_cleared.emit()
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
		starting_point = level.active_unit.board_position
	var subpath = level.nav_map.find_path(starting_point, point).slice(1)
	mp_cost += subpath.size()
	# set_viable_moves(point, level.active_unit.movement_points - mp_cost)
	viable_moves = level.nav_map.get_all_valid_moves(point, active_unit.movement_points - mp_cost)
	planned_path.append(subpath)
	_draw_available_moves()
	_mark_planned_path()

# VIABLE MOVES / ALL POTENTIAL MOVES

## Remove all viable moves from the board. This is purely visuals, does not actually clear what the game considers as viable moves, although it may be used in conjunction with that function, as in the [deactivate] method.
func _clear_viable_moves() -> void:
	for child in _viable_move_holder.get_children():
		child.queue_free()


## Remove all potential player moves from the board. This is purely visuals, does not actually clear what the game considers as potential player moves, although it may be used in conjunction with that function, as in the [deactivate] method.
func _clear_all_moves() -> void:
	for child in _all_move_holder.get_children():
		child.queue_free()


## Fully redraw the game's move highlights, including both viable moves which the player can route to and potential moves which the player can reach but not while following their current planned path.
func _draw_available_moves():
	_clear_viable_moves()
	_clear_all_moves()

	var seen : Dictionary[Vector3, bool]
	for move in viable_moves:
		seen[move] = true
		var highlight_scene = HIGHLIGHT.instantiate()
		highlight_scene.position = NavigableGridMap.convert_grid_to_global_position(move)
		_viable_move_holder.add_child(highlight_scene)
	if !planned_path.is_empty():
		for move in all_unit_moves:
			if !seen.has(move):
				var highlight_scene = UNAVAILABLE_HIGHLIGHT.instantiate()
				highlight_scene.position = NavigableGridMap.convert_grid_to_global_position(move)
				_all_move_holder.add_child(highlight_scene)

# LIFE CYCLE

## Called when the movement options are initialized, usually when a unit activates or becomes able to move again.
func activate(unit : Unit) -> void:
	active_unit = unit
	all_unit_moves = level.nav_map.get_all_valid_moves(unit.board_position, unit.movement_points)
	viable_moves = all_unit_moves
	planned_path = []
	hovered_path = []

	if active_unit is FriendlyUnit:
		_draw_available_moves()


## Called when the movement system needs to be deactivated and no valid moves are to be shown to the player, such as when a unit is deactivated, or arms a skill.
func deactivate() -> void:
	active_unit = null
	all_unit_moves = []
	viable_moves = []

	_clear_viable_moves()
	_clear_all_moves()
	wipe_planned_path()
	clear_hovered_path()
