@tool
class_name Unit
extends AnimatableBody3D

@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		global_position = NavigableGridMapV2.convert_grid_to_global_position(tile_position, true)
		if debug_label:
			debug_label.change_param('x', str(round(tile_position.x)))
			debug_label.change_param('y', str(round(tile_position.y)))
			debug_label.change_param('z', str(round(tile_position.z)))

@export var max_movement := 4

var potential_moves : Array[Vector3] = []
var can_move := true

@onready var _cell_highlight := %CellHighlight

@onready var state_machine : StateMachine = %StateMachine

@onready var debug_label : DebugLabel = %DebugLabel

func _ready():
	debug_label.change_param('x', str(round(tile_position.x)))
	debug_label.change_param('y', str(round(tile_position.y)))
	debug_label.change_param('z', str(round(tile_position.z)))


func set_valid_moves(moves : Array[Vector3]) -> void:
	potential_moves = moves


func activate():
	_cell_highlight.visible = true


func deactivate():
	_cell_highlight.visible = false


func reset():
	can_move = true
	

func check_for_detection() -> bool:
	return false


func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		state_machine.current_state.transition('FinishedMoving')
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()