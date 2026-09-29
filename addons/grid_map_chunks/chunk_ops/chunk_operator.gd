@tool
class_name ChunkOperator
extends Object

## Constant representing what should remain as the only path to saved chunks in the project. Likewise, all files within this directory should be Chunk resources, with no subdirectories.
static var SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"
static var grid_map_plugin : GridMapEditorPlugin
static var grid_map : GridMap
static var preview_layer : GridMap
static var preview_map : Dictionary[Vector3i, Vector2i] = {}
static var preview_mesh_lib : MeshLibrary
static var preview_origin := Vector3i.ZERO

var chunk_loader := ChunkLoader.new()
var chunk_saver := ChunkSaver.new()


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


func _create_preview_layer() -> void:
	_clear_preview_layer()
	preview_layer = grid_map.duplicate()
	preview_layer.position = Vector3.ZERO
	preview_layer.clear()
	grid_map.add_child(preview_layer)
	_create_preview_mesh_lib()


func _clear_preview_layer() -> void:
	if preview_layer:
		preview_layer.free()


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


func attempt_chunk_preview(chunk : Chunk) -> bool:
	if !_resync_to_grid_map():
		return false
	
	chunk_loader.preview_chunk(chunk)
	return true


func attempt_chunk_load() -> bool:
	if !_resync_to_grid_map():
		return false
	
	chunk_loader.merge_preview()
	preview_map = {}
	return true

func cancel_load() -> void:
	preview_layer.clear()
	preview_map = {}