@tool
class_name ZoneEditUI
extends VBoxContainer

signal back_clicked()

@onready var _back_button : Button = %BackButton
@onready var _name_input : LineEdit = %NameInput
@onready var _prep_input : LineEdit = %PrepInput

var nav_zone : NavZone
var level : Level

func _ready() -> void:
	_back_button.pressed.connect(back_clicked.emit)


func activate(loaded_level : Level, loaded_nav_zone : NavZone) -> void:
	nav_zone = loaded_nav_zone
	level = loaded_level
	level.nav_zone_map.visible = true
	visible = true

	_name_input.text = nav_zone.name
	_prep_input.text = nav_zone.preposition

	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(level.nav_map)


func deactivate() -> void:
	nav_zone = null
	level = null
	visible = false
