@abstract class_name Directive
extends Resource

var acting_unit : EnemyUnit

func begin(unit : EnemyUnit) -> void:
	acting_unit = unit
	if !acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.connect(_on_finished_moving)
	if !acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.connect(_on_finished_acting)


func cancel() -> void:
	if acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.disconnect(_on_finished_moving)
	if acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.disconnect(_on_finished_acting)


func end() -> void:
	if acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.disconnect(_on_finished_moving)
	if acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.disconnect(_on_finished_acting)
	acting_unit.decision_director.finish_directive()


@abstract func check_if_finished() -> bool


func _on_finished_moving(_unit : Unit):
	if check_if_finished():
		end()


func _on_finished_acting(_unit : Unit):
	if check_if_finished():
		end()