@tool
## The UI of the dock which this extension uses to handle saving, loading and previewing map chunks.
extends Control

@onready var name_edit : LineEdit = %FileNameEdit
@onready var _option_holder : VBoxContainer = %OptionHolder

## Constant representing what should remain as the only path to saved chunks in the project. Likewise, all files within this directory should be Chunk resources, with no subdirectories.
const SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"

## The currently inputted file name to be used when saving new chunks through the UI.
var file_name : String:
	get():
		return name_edit.text

func _ready() -> void:
	_refresh_chunks()


## Forces a refresh of the list of available saved chunks. Happens automatically at key points, but is also triggered by the reset button, in the event of a desync between the UI and the project file structure.
func _refresh_chunks() -> void:
	for child : ChunkOption in _option_holder.get_children():
		child.previewed.disconnect(_preview_chunk)
		child.loaded.disconnect(_load_chunk)
		child.queue_free()
	var dir = DirAccess.open(SAVED_CHUNKS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var chunk : Chunk = load(SAVED_CHUNKS_PATH + file_name) as Chunk
				var option_scene = ChunkOption.new_option(chunk, file_name)
				option_scene.previewed.connect(_preview_chunk)
				option_scene.loaded.connect(_load_chunk)
				_option_holder.add_child(option_scene)
			file_name = dir.get_next()
	else:
		print("COULD NOT FIND DIRECTORY")


## Save a selected chunk to the file system, provided a selection is currently present and a valid file name is inputted in the line edit.
func _on_save_button_pressed() -> void:
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

	_save_chunk(file_name, selection, selection_range, grid_map)


## Utility function for fetching the active GridMap in the editor.
func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return

	return grid_map_plugins[0]


## Stringifies the selected GridMap data into a JSON object with it's own schema (see [Chunk.content] for more details).
func _serialize_points(points : Array, local_root : Vector3i, grid_map : GridMap) -> String:
	var result = {}
	for point : Vector3i in points:
		var local_point = point - local_root
		var key = _stringify_vector3(local_point)
		var cell = grid_map.get_cell_item(point)
		var cell_rotation = grid_map.get_cell_item_orientation(point)
		var value = str(cell) + "-" + str(cell_rotation)
		result[key] = value
	
	return JSON.stringify(result)


## Utility function for reducing a Vector3/Vector3i to a string (Vector3i(0, 1, 2) -> "0/1/2").
func _stringify_vector3(vector : Variant) -> String:
	if vector is Vector3 or vector is Vector3i:
		return str(vector.x) + "/" + str(vector.y) + "/" + str(vector.z)
	else:
		return ""


## Return a stringified vector to a full vector format ("0/1/2" -> Vector3(0.0, 1.0, 1.0)).
func _unstringify_vector3(string : String) -> Vector3:
	var axes = Array(string.split('/')).map(func (i): return int(i))
	return Vector3(axes[0], axes[1], axes[2])


## Serialize a chunk of map data as a reusable Chunk, and save that chunk to a tres in the file system.
func _save_chunk(name : String, points : Array, selection : AABB, grid_map : GridMap) -> void:
	var chunk = Chunk.new()

	chunk.dimensions = selection.size
	chunk.name = name
	chunk.content = _serialize_points(points, Vector3i(selection.position), grid_map)

	var error := ResourceSaver.save(chunk, SAVED_CHUNKS_PATH + name + '.tres')
    
	if error == OK:
		print("CHUNK SAVED")
		_refresh_chunks()
	else:
		print("FAILED TO SAVE. ERROR CODE: ", error)


## Set the selection of the current GridMap to the dimensions of the chunk, showing exactly how large it will be, and how many tiles it may potentially replace.
func _preview_chunk(chunk : Chunk) -> void:
	var grid_map_plugin : GridMapEditorPlugin = _get_grid_map_plugin()
	var position = grid_map_plugin.get_selection().position

	grid_map_plugin.set_selection(position, Vector3i(position) + chunk.dimensions)


## Load a Chunk resource and reconstruct it in the GridMap, at the current selection's root position.
func _load_chunk(chunk : Chunk) -> void:
	var grid_map_plugin : GridMapEditorPlugin = _get_grid_map_plugin()
	var local_root = grid_map_plugin.get_selection().position
	var grid_map = grid_map_plugin.get_current_grid_map()

	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = _unstringify_vector3(key)
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		grid_map.set_cell_item(local_root + position, cell_item, cell_rotation)
