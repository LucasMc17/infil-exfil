@tool
## Responsible for handling all operations related to loading and saving chunks in the 3d game space. Delegates tasks to the [ChunkLoader] and [ChunkSaver] as needed.
class_name ChunkOperator
extends Object

## Constant representing what should remain as the only path to saved chunks in the project. Likewise, all files within this directory should be Chunk resources, with no subdirectories.
static var SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"
## The current grid map plugin active within the editor.
static var grid_map_plugin : GridMapEditorPlugin
## The current grid map which the above [grid_map_plugin] corresponds to.
static var grid_map : GridMap
## An additional GridMap created as a direct child of the active [grid_map] to house chunk previews. Never given an owner, and so not saved in the scene tree when the scene is unloaded.
static var preview_layer : GridMap
## A dictionary representing the information of the chunk currently stored in the preview layer, if one has been loaded. Updates with translations and rotations after initial preview load.
static var preview_map : Dictionary[Vector3i, Vector2i] = {}
# NOTE: There may be a better way to accomplish a similar end goal by simply creating a new render layer and setting it's opacity to 0.5.
## A deep copy of the [MeshLibrary] loaded into the active [grid_map]. Each tile has its texture deep copied and alpha set to 0.5 so as to appear translucent in the preview layer.
static var preview_mesh_lib : MeshLibrary
## The local origin of the currently loaded chunk in the preview layer.
static var preview_origin := Vector3i.ZERO

## Module for handling all tasks related to loading in a saved chunk.
var chunk_loader := ChunkLoader.new()
## Module for handling all tasks related to saving a chunk to memory.
var chunk_saver := ChunkSaver.new()


## Utility function to ensure that the plugin is connected to the correct grid map editor plugin and active grid map. Called before most chunk operations to avoid unexpected behaviors. Returns a boolean indicating whether or not all required elements were found before attempting any operations.
func _resync_to_grid_map() -> bool:
	if !grid_map_plugin or !grid_map\
	or grid_map != grid_map_plugin.get_current_grid_map()\
	or !preview_layer or !preview_mesh_lib:
		print('resyncing to current grid map...')
		grid_map_plugin = _get_grid_map_plugin()
		if !grid_map_plugin:
			print("Error: No GridMap Editor Plugin found")
			return false
		grid_map = grid_map_plugin.get_current_grid_map()
		if !grid_map:
			print("Error: No active GridMap in Editor")
			return false
		_create_preview_layer()
		if !grid_map.mesh_library:
			print("Error: Active GridMap has no MeshLibrary resource assigned")
			return false
		_create_preview_mesh_lib()
	return true


## Utility function for fetching the active GridMap in the editor.
func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return

	return grid_map_plugins[0]


## Creates a deep copy of the [MeshLibrary] and all textures with opacity set to 0.5.
func _create_preview_mesh_lib() -> void:
	preview_mesh_lib = grid_map.mesh_library.duplicate(true)
	for mesh_id in preview_mesh_lib.get_item_list():
		var mesh = preview_mesh_lib.get_item_mesh(mesh_id)
		var mat = mesh.surface_get_material(0).duplicate(true)
		
		if mat and mat is StandardMaterial3D:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.5
		
		mesh.surface_set_material(0, mat)
	
	if preview_layer:
		preview_layer.mesh_library = preview_mesh_lib


## Creates the preview layer [GridMap] for use with the [ChunkLoader] module.
func _create_preview_layer() -> void:
	_clear_preview_layer()
	preview_layer = grid_map.duplicate()
	preview_layer.position = Vector3.ZERO
	preview_layer.clear()
	grid_map.add_child(preview_layer)
	_create_preview_mesh_lib()


## Frees the current preview layer from memory to avoid an orphaned scene in memory.
func _clear_preview_layer() -> void:
	if preview_layer:
		preview_layer.free()


## Attempts to use the [ChunkSaver] to save a chunk to memory, returning [true] if succesful and false alongside logging an error if something goes wrong.
func attempt_chunk_save(save_name : String) -> bool:
	if !save_name:
		print("INPUT A FILE NAME TO SAVE")
		return false

	if !_resync_to_grid_map():
		return false

	if !grid_map_plugin:
		print("NO ACTIVE GRID MAP PLUGIN")
		return false
	if !grid_map_plugin.has_selection():
		print("NO SELECTION")
		return false

	return chunk_saver.save_chunk(save_name)


## Attempts to use the [ChunkLoader] to load a chunk from memory into the preview layer. Returns [true] if succesful and false alongside logging an error if something goes wrong.
func attempt_chunk_preview(chunk : Chunk) -> bool:
	if !_resync_to_grid_map():
		return false
	
	chunk_loader.preview_chunk(chunk)
	return true


## Attempts to use the [ChunkLoader] to load a merge a chunk from the preview layer into the active [grid_map]. Returns [true] if succesful and false alongside logging an error if something goes wrong.
func attempt_chunk_load() -> bool:
	if !_resync_to_grid_map():
		return false
	
	chunk_loader.merge_preview()
	preview_map = {}
	return true


## Cancels the current preview and clears the preview layer.
func cancel_load() -> void:
	preview_layer.clear()
	preview_map = {}