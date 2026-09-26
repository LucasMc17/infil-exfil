@tool
## The UI of the dock which this extension uses to handle saving, loading and previewing map chunks.
extends Control

@onready var name_edit : LineEdit = %FileNameEdit
@onready var _option_holder : VBoxContainer = %OptionHolder

## Constant representing what should remain as the only path to saved chunks in the project. Likewise, all files within this directory should be Chunk resources, with no subdirectories.
const SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"

var grid_map_plugin : GridMapEditorPlugin
var grid_map : GridMap
var chunk_loader : ChunkLoader
var chunk_saver : ChunkSaver
var chunk_previewer : ChunkPreviewer
## The currently inputted file name to be used when saving new chunks through the UI.
var file_name : String:
	get():
		return name_edit.text

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	_resync_to_grid_map()
	_refresh_chunks()


func _resync_to_grid_map() -> void:
	grid_map_plugin = _get_grid_map_plugin()
	grid_map = grid_map_plugin.get_current_grid_map()
	chunk_loader = ChunkLoader.new(grid_map_plugin)
	chunk_saver = ChunkSaver.new(SAVED_CHUNKS_PATH)
	chunk_previewer = ChunkPreviewer.new(grid_map, grid_map_plugin, chunk_loader)

## Forces a refresh of the list of available saved chunks. Happens automatically at key points, but is also triggered by the reset button, in the event of a desync between the UI and the project file structure.
func _refresh_chunks() -> void:
	for child : ChunkOption in _option_holder.get_children():
		child.previewed.disconnect(_on_preview_button_pressed)
		child.loaded.disconnect(_on_load_button_pressed)
		child.queue_free()
	var dir = DirAccess.open(SAVED_CHUNKS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var chunk : Chunk = load(SAVED_CHUNKS_PATH + file_name) as Chunk
				var option_scene = ChunkOption.new_option(chunk, file_name)
				option_scene.previewed.connect(_on_preview_button_pressed)
				option_scene.loaded.connect(_on_load_button_pressed)
				_option_holder.add_child(option_scene)
			file_name = dir.get_next()
	else:
		print("COULD NOT FIND DIRECTORY")


## Save a selected chunk to the file system, provided a selection is currently present and a valid file name is inputted in the line edit.
func _on_save_button_pressed() -> void:
	if !grid_map or grid_map != grid_map_plugin.get_current_grid_map():
		_resync_to_grid_map()
	if !file_name:
		print("INPUT A FILE NAME TO SAVE")
		return
	
	var grid_map_plugin : GridMapEditorPlugin = _get_grid_map_plugin()
	var grid_map = grid_map_plugin.get_current_grid_map()

	if !grid_map_plugin.has_selection():
		print("NO SELECTION")
		return

	var selection_range = grid_map_plugin.get_selection()
	var selection = grid_map_plugin.get_selected_cells()

	if chunk_saver.save(file_name, selection, selection_range, grid_map):
		print("CHUNK SAVED")
		_refresh_chunks()
	else:
		print("FAILED TO SAVE")


## Utility function for fetching the active GridMap in the editor.
func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return

	return grid_map_plugins[0]


## Load a Chunk resource via the ChunkLoader and reconstruct it in the GridMap, at the current selection's root position.
func _on_load_button_pressed(chunk : Chunk) -> void:
	if !grid_map or grid_map != grid_map_plugin.get_current_grid_map():
		_resync_to_grid_map()
	var grid_map_plugin = _get_grid_map_plugin()
	chunk_loader.load(grid_map, chunk)


func _on_preview_button_pressed(chunk : Chunk) -> void:
	if !grid_map or grid_map != grid_map_plugin.get_current_grid_map():
		_resync_to_grid_map()
	chunk_previewer.preview(chunk)
# TODO:
	# Better chunk visualization
	# Rotation solution