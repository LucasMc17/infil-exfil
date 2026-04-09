@tool
class_name Unit extends Node3D

@export var tile_position := Vector3i.ZERO:
	set(val):
		tile_position = val
		if Engine.is_editor_hint():
			snap_to_position()


func snap_to_position() -> void:
	var temp = tile_position
	temp.y *= 4
	position = temp as Vector3 + Vector3(0.5, 0, 0.5)