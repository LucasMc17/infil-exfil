@tool
## Handles the actual act of loading a chunk into the grid map, including connecting to the editor's undo/redo manager.
class_name ChunkLoader
extends Object

## Set the selection of the current GridMap to the dimensions of the chunk, showing exactly how large it will be, and how many tiles it may potentially replace.
func preview_chunk(chunk : Chunk) -> void:
	ChunkOperator.in_preview = true
	var cell_map : Dictionary[Vector3i, Vector2i] = chunk.to_dict()

	set_grid_map_contents(ChunkOperator.preview_layer, cell_map)

	# grid_map_plugin.set_selection(position, Vector3i(position) + chunk.dimensions)


func _convert_chunk_to_dict(chunk : Chunk) -> Dictionary[Vector3i, Vector2i]:
	var result : Dictionary[Vector3i, Vector2i] = {}
	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = Vector3i(Chunk.unstringify_vector3(key))
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		result[Vector3i(ChunkOperator.grid_map_plugin.get_selection().position) + position] = Vector2i(cell_item, cell_rotation)
	return result


## clears and then rebuilds the grid map's cells using a dictionary where each key is a Vector3i representing the cell's position, and each value is a Vector2i representing the cell item type and rotation. For use with the undo/redo manager.
func set_grid_map_contents(grid_map : GridMap, cell_map : Dictionary[Vector3i, Vector2i]) -> void:
	grid_map.clear()
	for cell in cell_map.keys():
		var value = cell_map[cell]
		var item = value.x
		var rotation = value.y

		grid_map.set_cell_item(cell, item, rotation)


# TODO: Undo redo breaks when using this to preview chunks. Might not even need undo redo for previews.
## Main function for loading map chunks into the grid map.
func load_chunk(map : GridMap, chunk : Chunk) -> void:
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Load Chunk")

	var local_root = Vector3i(ChunkOperator.grid_map_plugin.get_selection().position)

	var old_cell_map : Dictionary[Vector3i, Vector2i] = {}
	for cell in map.get_used_cells():
		old_cell_map[cell] = Vector2i(map.get_cell_item(cell), map.get_cell_item_orientation(cell))
	
	var new_cell_map : Dictionary[Vector3i, Vector2i] = old_cell_map.duplicate()
	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = Vector3i(Chunk.unstringify_vector3(key))
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		new_cell_map[local_root + position] = Vector2i(cell_item, cell_rotation)

	undo_redo.add_do_method(self, "set_grid_map_contents", map, new_cell_map)
	undo_redo.add_undo_method(self, "set_grid_map_contents", map, old_cell_map)
	undo_redo.commit_action(true)

