class_name MoveToPointAction
extends Action

@export var _end_point := Vector3.ZERO

func begin(unit : EnemyUnit) -> void:
	unit.state_machine.current_state.transition('MoveToPoint', { "end_point": _end_point})


func end(unit : EnemyUnit) -> void:
	pass
