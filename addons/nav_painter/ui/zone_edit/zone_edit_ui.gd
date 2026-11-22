@tool
class_name ZoneEditUI
extends VBoxContainer

## Emitted when the user clicks back to select another NavZone to edit.
signal back_clicked()

@onready var _back_button : Button = %BackButton
@onready var _delete_button : Button = %DeleteButton
@onready var _inspector : EditorInspector = %EditorInspector

@onready var _area_button : Button = %AreaButton
@onready var _point_button : Button = %PointButton
@onready var _exit_button : Button = %ExitButton

@onready var _delete_dialog : ConfirmationDialog = %ConfirmDeletion

var nav_zone : NavZone
var level : Level

func _ready() -> void:
	_back_button.pressed.connect(back_clicked.emit)
	_area_button.pressed.connect(_new_area)
	_point_button.pressed.connect(_new_point)
	_exit_button.pressed.connect(_new_exit)
	_delete_button.pressed.connect(_delete_dialog.popup_centered)
	_delete_dialog.confirmed.connect(_on_delete_confirmed)


## Activate and set up the UI slice.
func activate(loaded_level : Level, loaded_nav_zone : NavZone) -> void:
	nav_zone = loaded_nav_zone
	level = loaded_level
	level.nav_system.visible = true
	visible = true

	_area_button.disabled = false
	_point_button.disabled = false
	_exit_button.disabled = false

	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(level.nav_map)

	_inspector.edit(nav_zone)


## Deactivat the UI slice when the user navigates away.
func deactivate() -> void:
	nav_zone = null
	level = null
	visible = false

	_area_button.disabled = true
	_point_button.disabled = true
	_exit_button.disabled = true


## Create a new NavZoneArea for the chosen NavZone, when the user requests it.
func _new_area() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	if !plugin:
		return

	var selection : AABB = plugin.get_selection()
	var size = Vector2i(selection.size.x + 1, selection.size.z + 1)
	var area = NavZoneArea.new()
	area.position = selection.position
	area.dimensions = size

	var old_areas = nav_zone.areas.duplicate()

	var new_areas = old_areas.duplicate()
	new_areas.append(area)

	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Add NavZone Area")
	undo_redo.add_do_property(nav_zone, "areas", new_areas)
	undo_redo.add_undo_property(nav_zone, "areas", old_areas)
	undo_redo.commit_action()


## Create a new point for the chosen NavZone, when the user requests it.
func _new_point() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	if !plugin:
		return

	var selection : AABB = plugin.get_selection()

	var old_points = nav_zone.points.duplicate()

	var new_points = old_points.duplicate()
	new_points.append(selection.position)

	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Add NavZone Point")
	undo_redo.add_do_property(nav_zone, "points", new_points)
	undo_redo.add_undo_property(nav_zone, "points", old_points)
	undo_redo.commit_action()


## Create a new exit for the chosen NavZone, when the user requests it.
func _new_exit() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	if !plugin:
		return

	var selection : AABB = plugin.get_selection()

	var old_exits = nav_zone.exits.duplicate()

	var new_exits = old_exits.duplicate()

	var exit = NavZoneExit.new()
	exit.position = selection.position

	new_exits.append(exit)

	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Add NavZone Exit")
	undo_redo.add_do_property(nav_zone, "exits", new_exits)
	undo_redo.add_undo_property(nav_zone, "exits", old_exits)
	undo_redo.commit_action()


## Fully deletes a NavZone from memory.
func _on_delete_confirmed() -> void:
	if !level or !nav_zone:
		printerr("Something went wrong, please try again...")
		return
	level.nav_system.nav_zones = level.nav_system.nav_zones.filter(func (zone : NavZone): return zone != nav_zone)
	var path = nav_zone.resource_path
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error != OK:
			printerr(error)
