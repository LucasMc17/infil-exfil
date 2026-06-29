## A specific Directive representing moving towards a specific point on the NavGrid. Is considered finished when the unit finishes moving to that point.
class_name MoveToPoint
extends Directive

## The point to move towards.
@export var _end_point := Vector3.ZERO

func begin(unit : EnemyUnit) -> void:
	super(unit)
	unit.movement_machine.current_state.transition('Walk', { "end_point": _end_point})


func check_if_finished() -> bool:
	return acting_unit.tile_position == _end_point


func _on_finished_moving(unit : Unit):
	super(unit)
	unit.forfeit_turn()