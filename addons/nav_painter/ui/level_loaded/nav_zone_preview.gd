@tool
class_name NavZonePreview
extends HBoxContainer

signal find_requested(zone : NavZone)
signal edit_requested(zone : NavZone)

@onready var _name_label : Label = %NameLabel
@onready var _file_label : Label = %FileLabel
@onready var _find_button : Button = %FindButton
@onready var _edit_button : Button = %EditButton

## The Packed Scene of this UI element, for instantiating new instances.
const SCENE : PackedScene = preload("uid://berq43r8bxkbk")

var zone : NavZone
var file_name : String

## Main func for instantiating a new NavZonePreview in the NavPainting dock.
static func new_preview(z : NavZone) -> NavZonePreview:
	var preview : NavZonePreview = SCENE.instantiate()
	preview.zone = z
	return preview


func _ready() -> void:
	_name_label.text = zone.name
	_file_label.text = zone.resource_path.get_file()
	_find_button.pressed.connect(find_requested.emit.bind(zone))
	_edit_button.pressed.connect(edit_requested.emit.bind(zone))
