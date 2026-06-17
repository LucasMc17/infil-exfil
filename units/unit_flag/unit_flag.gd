class_name UnitFlag
extends Sprite3D

@onready var _content : UnitFlagContent = %UnitFlagContent

func expand() -> void:
	_content.handle_expand()


func collapse() -> void:
	_content.handle_collapse()


func refresh(unit : Unit) -> void:
	_content.handle_refresh(unit)