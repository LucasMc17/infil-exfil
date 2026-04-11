@tool
class_name CellHighlighter
extends Node3D

const HIGHLIGHT = preload("res://cell_highlight.tscn")

@export var highlighted_cells : Array[Vector3]:
	set(val):
		highlighted_cells = val
		clear()
		for pos in val:
			highlight_cell(pos)

func clear() -> void:
	for child in get_children():
		child.queue_free()

func highlight_cell(pos : Vector3) -> void:
	var highlight_scene = HIGHLIGHT.instantiate()
	var temp = pos
	temp.x += 0.5
	temp.z += 0.5
	temp.y *= 4
	add_child(highlight_scene)
	highlight_scene.global_position = temp