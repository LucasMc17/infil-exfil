@tool
## Handles the actual act of loading a chunk into the grid map, including connecting to the editor's undo/redo manager.
class_name ChunkLoader
extends Object

## Set the selection of the current GridMap to the dimensions of the chunk, showing exactly how large it will be, and how many tiles it may potentially replace.
func preview_chunk(chunk : Chunk) -> void:
	var cell_map : Dictionary[Vector3i, Vector2i] = chunk.to_dict()

	ChunkOperator.preview_map = cell_map

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


func merge_preview() -> void:
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Load Chunk")
	var grid_map = ChunkOperator.grid_map
	var preview_layer = ChunkOperator.preview_layer

	var old_cell_map : Dictionary[Vector3i, Vector2i] = {}
	for cell in grid_map.get_used_cells():
		old_cell_map[cell] = Vector2i(grid_map.get_cell_item(cell), grid_map.get_cell_item_orientation(cell))

	var new_cell_map : Dictionary[Vector3i, Vector2i] = old_cell_map.duplicate()
	for cell in preview_layer.get_used_cells():
		new_cell_map[cell] = Vector2i(preview_layer.get_cell_item(cell), preview_layer.get_cell_item_orientation(cell))
	
	undo_redo.add_do_method(self, "set_grid_map_contents", grid_map, new_cell_map)
	undo_redo.add_undo_method(self, "set_grid_map_contents", grid_map, old_cell_map)
	undo_redo.commit_action(true)
	preview_layer.clear()


func translate_preview(direction : Vector3i) -> void:
	var new_map : Dictionary[Vector3i, Vector2i] = {}
	for position in ChunkOperator.preview_map.keys():
		var value = ChunkOperator.preview_map[position]
		var new_pos = position + direction
		new_map[new_pos] = value
	ChunkOperator.preview_map = new_map
	set_grid_map_contents(ChunkOperator.preview_layer, ChunkOperator.preview_map)
