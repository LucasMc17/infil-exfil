class_name DialogInspector
extends FoldableContainer

@onready var _log : RichTextLabel = %Log

func _ready() -> void:
	Events.unit_spoke.connect(_on_unit_spoke)


func _on_unit_spoke(unit : Unit, message : String) -> void:
	var new_line = unit.name + ": " + message + "\n"
	_log.text = new_line + _log.text
