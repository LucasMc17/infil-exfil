class_name NavPaintUtilities
extends Object

## The currently active grid map editor plugin
static var grid_map_editor_plugin : GridMapEditorPlugin

static func update_grid_map_plugin() -> void:
	if !grid_map_editor_plugin:
		var editor_root = EditorInterface.get_base_control().get_tree().root
		var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

		if grid_map_plugins.is_empty():
			print("NO ACTIVE GRID MAP PLUGIN")
			return

		grid_map_editor_plugin = grid_map_plugins[0]