@tool
class_name ZoneEditUI
extends VBoxContainer

signal back_clicked()

@onready var _back_button : Button = %BackButton
@onready var _inspector : EditorInspector = %EditorInspector

@onready var _area_button : Button = %AreaButton
@onready var _point_button : Button = %PointButton
@onready var _exit_button : Button = %ExitButton

var nav_zone : NavZone
var level : Level

func _ready() -> void:
	_back_button.pressed.connect(back_clicked.emit)
	_area_button.pressed.connect(_new_area)


func activate(loaded_level : Level, loaded_nav_zone : NavZone) -> void:
	nav_zone = loaded_nav_zone
	level = loaded_level
	level.nav_zone_map.visible = true
	visible = true

	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(level.nav_map)

	_inspector.edit(nav_zone)


func deactivate() -> void:
	nav_zone = null
	level = null
	visible = false


func _new_area() -> void:
	var plugin = _get_grid_map_plugin()

	if !plugin:
		return

	var selection : AABB = plugin.get_selection()
	var size = Vector2i(selection.size.x + 1, selection.size.z + 1)
	var position = Vector2i(selection.position.x, selection.position.z) - Vector2i(nav_zone.base_position.x , nav_zone.base_position.z)
	var rect = Rect2i(position, size)

	var old_areas = nav_zone.areas.duplicate()

	var new_areas = old_areas.duplicate()
	new_areas.append(rect)

	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Add NavZone Area")
	undo_redo.add_do_property(nav_zone, "areas", new_areas)
	undo_redo.add_undo_property(nav_zone, "areas", old_areas)
	undo_redo.commit_action()


func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		print("NO ACTIVE GRID MAP PLUGIN")
		return null

	var plugin : GridMapEditorPlugin = grid_map_plugins[0]

	if !plugin.has_selection():
		print("NO ACTIVE SELECTION")
		return null
	
	return plugin
