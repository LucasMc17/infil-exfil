@tool
class_name Unit
extends Node3D

@export var tile_position := Vector3i.ZERO:
	set(val):
		tile_position = val
		if Engine.is_editor_hint():
			snap_to_position()

@export var max_movement := 4

var potential_moves : Array[Vector3] = []
var can_move := true

func _ready():
	pass

func snap_to_position() -> void:
	var temp = tile_position
	temp.y *= 4
	position = temp as Vector3 + Vector3(0.5, 0, 0.5)


func move_to_position(pos : Vector3):
	can_move = false
	potential_moves = []
	tile_position = pos
	snap_to_position()