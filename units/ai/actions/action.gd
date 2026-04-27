@abstract class_name Action
extends Resource

var acting_unit : EnemyUnit

func begin(unit : EnemyUnit) -> void:
	acting_unit = unit
	Events.enemy_finished_moving.connect(_on_finished_moving)


func end() -> void:
	Events.enemy_finished_moving.disconnect(_on_finished_moving)
	acting_unit.action_director.finish_action()


@abstract func check_if_finished() -> bool


func _on_finished_moving(unit : EnemyUnit):
	if unit == acting_unit and check_if_finished():
		end()