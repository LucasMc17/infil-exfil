@tool
## The UI of the dock which this extension uses to handle making edits to nav zones.
class_name NavPainterDock
extends Control

@onready var _no_level_ui : NoLevelUI = %NoLevelUI
@onready var _level_loaded_ui : LevelLoadedUI = %LevelLoadedUI
@onready var _zone_edit_ui : ZoneEditUI = %ZoneEditUI

## The level loaded into the editor.
var loaded_level : Level

func _ready() -> void:
	_check_for_level()
	visibility_changed.connect(_on_visibility_changed)
	_no_level_ui.refresh_requested.connect(_check_for_level)
	_level_loaded_ui.zone_edit_requested.connect(_switch_to_zone_edit_ui)
	_zone_edit_ui.back_clicked.connect(_check_for_level)


func _check_for_level() -> void:
	var plugin = Utilities.get_grid_map_plugin()
	if plugin:
		plugin.clear_selection()
	var level = EditorInterface.get_edited_scene_root()
	if level is Level:
		_switch_to_level_loaded_ui(level)
	else:
		_switch_to_no_level_ui()
	

## A level has been loaded for editing, switch to the appropriate UI.
func _switch_to_level_loaded_ui(level : Level) -> void:
	loaded_level = level
	_no_level_ui.deactivate()
	_zone_edit_ui.deactivate()
	_level_loaded_ui.activate(level)


## No level has been found for editing, switch to the appropriate UI.
func _switch_to_no_level_ui() -> void:
	_no_level_ui.activate()
	_zone_edit_ui.deactivate()
	_level_loaded_ui.deactivate()


## A NavZone has been selected for editing, switch to the appropriate UI.
func _switch_to_zone_edit_ui(zone : NavZone) -> void:
	_level_loaded_ui.deactivate()
	_zone_edit_ui.activate(loaded_level, zone)
	_no_level_ui.deactivate()


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_check_for_level()
	else:
		_switch_to_no_level_ui()