@tool
## Handles the actual act of loading a chunk into the grid map, including connecting to the editor's undo/redo manager.
class_name ChunkLoader
extends Object


# TODO: Find a way to do this efficiently
func _create_preview_mesh_lib() -> void:
	MapChunkDock.current.preview_mesh_lib = MapChunkDock.current.grid_map.mesh_library.duplicate(true)
	for mesh_id in MapChunkDock.current.preview_mesh_lib.get_item_list():
		var mesh = MapChunkDock.current.preview_mesh_lib.get_item_mesh(mesh_id)
		var mat = mesh.surface_get_material(0).duplicate(true)
		
		if mat and mat is StandardMaterial3D:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.5
		
		mesh.surface_set_material(0, mat)
	
	if MapChunkDock.current.preview_layer:
		MapChunkDock.current.preview_layer.mesh_library = MapChunkDock.current.preview_mesh_lib

func create_preview_layer() -> void:
	clear_preview_layer()
	MapChunkDock.current.preview_layer = MapChunkDock.current.grid_map.duplicate()
	MapChunkDock.current.preview_layer.position = Vector3.ZERO
	MapChunkDock.current.preview_layer.clear()
	MapChunkDock.current.grid_map.add_child(MapChunkDock.current.preview_layer)
	_create_preview_mesh_lib()


func clear_preview_layer() -> void:
	if MapChunkDock.current.preview_layer:
		MapChunkDock.current.preview_layer.free()


## Set the selection of the current GridMap to the dimensions of the chunk, showing exactly how large it will be, and how many tiles it may potentially replace.
func preview(chunk : Chunk) -> void:

	create_preview_layer()

	load_chunk(MapChunkDock.current.preview_layer, chunk)

	# grid_map_plugin.set_selection(position, Vector3i(position) + chunk.dimensions)

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


# TODO: Undo redo breaks when using this to preview chunks. Might not even need undo redo for previews.
## Main function for loading map chunks into the grid map.
func load_chunk(map : GridMap, chunk : Chunk) -> void:
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Load Chunk")

	var local_root = Vector3i(MapChunkDock.current.grid_map_plugin.get_selection().position)

	var old_cell_map : Dictionary[Vector3i, Vector2i] = {}
	for cell in map.get_used_cells():
		old_cell_map[cell] = Vector2i(map.get_cell_item(cell), map.get_cell_item_orientation(cell))
	
	var new_cell_map : Dictionary[Vector3i, Vector2i] = old_cell_map.duplicate()
	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = Vector3i(_unstringify_vector3(key))
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		new_cell_map[local_root + position] = Vector2i(cell_item, cell_rotation)

	undo_redo.add_do_method(self, "set_grid_map_contents", map, new_cell_map)
	undo_redo.add_undo_method(self, "set_grid_map_contents", map, old_cell_map)
	undo_redo.commit_action(true)

