## The flag displaying information about units to the player, as a 3D scene.
class_name UnitFlag
extends Sprite3D

@onready var _content : UnitFlagContent = %UnitFlagContent

## Pass along the signal to expand to the flag's content.
func expand() -> void:
	_content.handle_expand()


## Pass along the signal to collapse to the flag's content.
func collapse() -> void:
	_content.handle_collapse()


## Pass along the signal to refresh the flag's content with the latest data from the source unit.
func refresh(unit : Unit) -> void:
	_content.handle_refresh(unit)