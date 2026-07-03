class_name PathMarkingSystem extends Node3D

## Preloaded path marker sprite scene.
const PATH_MARKER := preload('res://navigation/path_marking/path_marker.tscn')

## The currently considered path.
var path : PackedVector3Array = []

## Mark the intended path for the player's benefit.
func mark_path(steps : PackedVector3Array) -> void:
	clear_path()
	path = steps
	for cell in steps:
		var path_marker_scene = PATH_MARKER.instantiate()
		path_marker_scene.position = NavigableGridMap.convert_grid_to_global_position(cell)
		add_child(path_marker_scene)


## Clears the path_markers from the level scene.
func clear_path() -> void:
	path = []
	for child in get_children():
		child.queue_free()