@tool
## Node responsible for highlighting cells in the navgrid to show their availability for navigating to.
class_name CellHighlighter
extends Node3D

## The cell highlight scene.
const HIGHLIGHT = preload("res://cell_highlight.tscn")

## The currently highlighted cells, exported for testing in-editor.
@export var highlighted_cells : Array[Vector3]:
	set(val):
		highlighted_cells = val
		clear()
		for pos in val:
			highlight_cell(pos)


## Clear all the highlights in the level.
func clear() -> void:
	for child in get_children():
		child.queue_free()


## Highlight a specific cell by its 3D coordinates.
func highlight_cell(pos : Vector3) -> void:
	var highlight_scene = HIGHLIGHT.instantiate()
	add_child(highlight_scene)
	highlight_scene.global_position = NavigableGridMap.convert_grid_to_global_position(pos, true)