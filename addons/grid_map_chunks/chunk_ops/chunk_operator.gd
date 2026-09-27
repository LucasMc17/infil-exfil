@tool
class_name ChunkOperator
extends Object

## Constant representing what should remain as the only path to saved chunks in the project. Likewise, all files within this directory should be Chunk resources, with no subdirectories.
static var SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"
static var grid_map_plugin : GridMapEditorPlugin
static var grid_map : GridMap
static var preview_layer : GridMap
static var preview_mesh_lib : MeshLibrary
static var in_preview := false:
	set(val):
		in_preview = val
		if !val:
			preview_layer.clear()
var chunk_loader := ChunkLoader.new()
var chunk_saver := ChunkSaver.new()

func _resync_to_grid_map() -> void:
	if !grid_map_plugin or !grid_map or grid_map != grid_map_plugin.get_current_grid_map():
		grid_map_plugin = _get_grid_map_plugin()
		grid_map = grid_map_plugin.get_current_grid_map()


## Utility function for fetching the active GridMap in the editor.
func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return

	return grid_map_plugins[0]


func attempt_chunk_save(save_name : String) -> bool:
	if !save_name:
		print("INPUT A FILE NAME TO SAVE")
		return false

	_resync_to_grid_map()

	if !grid_map_plugin:
		print("NO ACTIVE GRID MAP PLUGIN")
		return false
	if !grid_map_plugin.has_selection():
		print("NO SELECTION")
		return false

	return chunk_saver.save_chunk(save_name)