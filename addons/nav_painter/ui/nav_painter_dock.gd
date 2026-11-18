@tool
## The UI of the dock which this extension uses to handle making edits to nav zones.
class_name NavPainterDock
extends Control

@onready var _no_level_ui : NoLevelUI = %NoLevelUI
@onready var _level_loaded_ui : LevelLoadedUI = %LevelLoadedUI

func _ready() -> void:
	_check_for_level()
	visibility_changed.connect(_check_for_level)
	_no_level_ui.refresh_requested.connect(_check_for_level)


func _check_for_level() -> void:
	var level = EditorInterface.get_edited_scene_root()
	if level is Level:
		_switch_to_level_loaded_ui(level)
	else:
		_switch_to_no_level_ui()


func _switch_to_level_loaded_ui(level : Level) -> void:
	_no_level_ui.visible = false
	_level_loaded_ui.activate(level)


func _switch_to_no_level_ui() -> void:
	_no_level_ui.visible = true
	_level_loaded_ui.deactivate()