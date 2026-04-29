@tool
class_name Unit
extends AnimatableBody3D

signal started_moving(unit : Unit)
signal finished_moving(unit : Unit)
signal started_acting(unit : Unit)
signal finished_acting(unit : Unit)
signal forfeited_turn(unit : Unit)

@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		global_position = NavigableGridMapV2.convert_grid_to_global_position(tile_position, true)
		if debug_label:
			debug_label.change_param('x', str(round(tile_position.x)))
			debug_label.change_param('y', str(round(tile_position.y)))
			debug_label.change_param('z', str(round(tile_position.z)))

@export var max_movement := 4

@export var max_movement_points := 1
@export var max_action_points := 1

var potential_moves : Array[Vector3] = []
var movement_points := max_movement_points
var action_points := max_action_points
var is_active : bool:
	get():
		return World.level.active_unit == self

@onready var _cell_highlight := %CellHighlight

@onready var movement_machine : MovementMachine = %MovementMachine
@onready var action_machine : ActionMachine = %ActionMachine

@onready var debug_label : DebugLabel = %DebugLabel

func _ready():
	debug_label.change_param('x', str(round(tile_position.x)))
	debug_label.change_param('y', str(round(tile_position.y)))
	debug_label.change_param('z', str(round(tile_position.z)))


# NOTE: There's a lot more to do here. Right now this is called when the unit is activated, or enters or exits a movmement state. I think there could be a more elegant solution, utilizing signals to determine when the list of available moves should be updated. I am also considering changing the level cell highlighter from the global level to a per unit level, then just swapping its visibility as the unit is activated/deactivated.
func refresh_valid_moves():
	var valid_moves : Array[Vector3] = []
	if World.level and can_move():
		valid_moves = World.level.nav_map.get_all_valid_moves(tile_position, max_movement)
	if World.level and is_active:
		World.level.cell_highlighter.highlighted_cells = valid_moves
	potential_moves = valid_moves


func activate():
	_cell_highlight.visible = true
	refresh_valid_moves()


func deactivate():
	_cell_highlight.visible = false


func reset():
	movement_points = max_movement_points
	action_points = max_action_points


# NOTE: I don't like these.
func can_move() -> bool:
	return movement_points > 0 and movement_machine.current_state is NoMovement


func can_act() -> bool:
	return action_points > 0 and action_machine.current_state is NoAction


func forfeit_turn() -> void:
	movement_points = 0
	action_points = 0
	forfeited_turn.emit(self)


func check_for_detection() -> bool:
	return false


func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		movement_machine.current_state.transition('NoMovement')
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()