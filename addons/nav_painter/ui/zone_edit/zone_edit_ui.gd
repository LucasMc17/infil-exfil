@tool
class_name ZoneEditUI
extends VBoxContainer

signal back_clicked()

@onready var _back_button : Button = %BackButton
@onready var _inspector : EditorInspector = %EditorInspector

var nav_zone : NavZone
var level : Level

func _ready() -> void:
	_back_button.pressed.connect(back_clicked.emit)


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
