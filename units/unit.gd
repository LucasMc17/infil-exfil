@tool
class_name Unit
extends AnimatableBody3D

@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		global_position = NavigableGridMapV2.convert_grid_to_global_position(tile_position, true)

@export var max_movement := 4

var potential_moves : Array[Vector3] = []
var can_move := true

@onready var _cell_highlight := %CellHighlight

@onready var state_machine : StateMachine = %StateMachine

# func move_to_position(pos : Vector3):
# 	can_move = false
# 	potential_moves = []
# 	tile_position = pos


func set_valid_moves(moves : Array[Vector3]) -> void:
	potential_moves = moves


func activate():
	_cell_highlight.visible = true


func deactivate():
	_cell_highlight.visible = false


func check_for_detection():
	pass


func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		state_machine.current_state.transition('Idle')
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()
		check_for_detection()