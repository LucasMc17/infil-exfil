class_name UnitSightingInspector
extends HBoxContainer

@onready var _unit_name : Button = %UnitName
@onready var _sight_status : Label = %SightStatus
@onready var _last_position : Button = %LastPosition

var sighting : UnitKnowledgeModule.Sighting

static func new_inspector(sighting : UnitKnowledgeModule.Sighting) -> UnitSightingInspector:
	var inspector = load("uid://c8iio3w5c60dk").instantiate()
	inspector.sighting = sighting
	return inspector


func _ready() -> void:
	if sighting:
		_unit_name.text = sighting.unit.name
		_sight_status.text = "IN SIGHT" if sighting.still_in_sight else "OUT OF SIGHT"
		_last_position.text = str(sighting.last_known_position)

		_unit_name.pressed.connect(_on_name_button_pressed)
		_last_position.pressed.connect(_on_lkp_pressed)


func _on_name_button_pressed() -> void:
	Level.current.level_camera.jump_to_point(sighting.unit.board_position)


func _on_lkp_pressed() -> void:
	Level.current.level_camera.jump_to_point(sighting.last_known_position)
