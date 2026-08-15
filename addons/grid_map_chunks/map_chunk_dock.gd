@tool
extends Control

@onready var name_edit : LineEdit = %FileNameEdit
@onready var _option_holder : VBoxContainer = %OptionHolder

const SAVED_CHUNKS_PATH : String = "res://addons/grid_map_chunks/saved_chunks/"

var file_name : String:
	get():
		return name_edit.text

func _ready() -> void:
	_refresh_chunks()


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
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func _on_test_button_pressed() -> void:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return
	
	if !file_name:
		print("INPUT A FILE NAME TO SAVE")
		return

	var grid_map_plugin : GridMapEditorPlugin = grid_map_plugins[0]
	var grid_map = grid_map_plugin.get_current_grid_map()

	if !grid_map_plugin.has_selection():
		print("NO SELECTION")
		return

	var selection_range = grid_map_plugin.get_selection()
	var selection = grid_map_plugin.get_selected_cells()

	_save_chunk(file_name, selection, selection_range, grid_map)


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


func _stringify_vector3(vector : Variant) -> String:
	if vector is Vector3 or vector is Vector3i:
		return str(vector.x) + "/" + str(vector.y) + "/" + str(vector.z)
	else:
		return ""


func _unstringify_vector3(string : String) -> Vector3:
	var axes = Array(string.split('/')).map(func (i): return int(i))
	return Vector3(axes[0], axes[1], axes[2])


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


func _preview_chunk(chunk : Chunk) -> void:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return
	
	var grid_map_plugin : GridMapEditorPlugin = grid_map_plugins[0]
	var position = grid_map_plugin.get_selection().position

	grid_map_plugin.set_selection(position, Vector3i(position) + chunk.dimensions)


func _load_chunk(chunk : Chunk) -> void:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return
	
	var grid_map_plugin : GridMapEditorPlugin = grid_map_plugins[0]
	var local_root = grid_map_plugin.get_selection().position
	var grid_map = grid_map_plugin.get_current_grid_map()

	var data = JSON.parse_string(chunk.content)
	for key in data.keys():
		var position = _unstringify_vector3(key)
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		grid_map.set_cell_item(local_root + position, cell_item, cell_rotation)


func _on_refresh_button_pressed() -> void:
	_refresh_chunks()
