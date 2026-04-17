@tool
class_name Unit
extends Node3D

@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		global_position = NavigableGridMapV2.convert_grid_to_global_position(tile_position, true)

@export var max_movement := 4

var potential_moves : Array[Vector3] = []
var can_move := true

@onready var _cell_highlight := %CellHighlight

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


func follow_path(delta : float, path : Array, mps := 1.0):
	if path.is_empty():
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()
		# vision_zone.queue_vision_test()