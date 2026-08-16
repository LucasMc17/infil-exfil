@tool
## Handles the actual act of loading a chunk into the grid map, including connecting to the editor's undo/redo manager.
class_name ChunkLoader
extends Resource

## Return a stringified vector to a full vector format ("0/1/2" -> Vector3(0.0, 1.0, 1.0)).
func _unstringify_vector3(string : String) -> Vector3:
	var axes = Array(string.split('/')).map(func (i): return int(i))
	return Vector3(axes[0], axes[1], axes[2])


## clears and then rebuilds the grid map's cells using a dictionary where each key is a Vector3i representing the cell's position, and each value is a Vector2i representing the cell item type and rotation. For use with the undo/redo manager.
func set_grid_map_contents(grid_map : GridMap, cell_map : Dictionary[Vector3i, Vector2i]) -> void:
	grid_map.clear()
	for cell in cell_map.keys():
		var value = cell_map[cell]
		var item = value.x
		var rotation = value.y

		grid_map.set_cell_item(cell, item, rotation)


## Main function for loading map chunks into the grid map.
func load_chunk(grid_map_plugin : GridMapEditorPlugin, chunk : Chunk) -> void:
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Load Chunk")

	var grid_map = grid_map_plugin.get_current_grid_map()
	var local_root = Vector3i(grid_map_plugin.get_selection().position)

	var old_cell_map : Dictionary[Vector3i, Vector2i] = {}
	for cell in grid_map.get_used_cells():
		old_cell_map[cell] = Vector2i(grid_map.get_cell_item(cell), grid_map.get_cell_item_orientation(cell))
	
	var new_cell_map : Dictionary[Vector3i, Vector2i] = old_cell_map.duplicate()
	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = Vector3i(_unstringify_vector3(key))
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		new_cell_map[local_root + position] = Vector2i(cell_item, cell_rotation)

	undo_redo.add_do_method(self, "set_grid_map_contents", grid_map, new_cell_map)
	undo_redo.add_undo_method(self, "set_grid_map_contents", grid_map, old_cell_map)
	undo_redo.commit_action(true)

