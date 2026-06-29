## A resource representing a specific goal for an AI-controlled unit to complete. Can range from moving to a point to attacking an enemy, to running for an alarm. Designed to be queued and executed in order.
@abstract class_name Directive
extends Resource

## The unit completing this directive.
var acting_unit : EnemyUnit

## Executed when the unit begins to fulfill this directive.
func begin(unit : EnemyUnit) -> void:
	acting_unit = unit
	if !acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.connect(_on_finished_moving)
	if !acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.connect(_on_finished_acting)


## Executed when this directive is canceled, and exited before it can be completed, usually because a higher priority directive has jumped to the front of the queue.
func cancel() -> void:
	if acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.disconnect(_on_finished_moving)
	if acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.disconnect(_on_finished_acting)


## Executed when the directive is successfully completed and removed from the queue.
func end() -> void:
	if acting_unit.finished_moving.is_connected(_on_finished_moving):
		acting_unit.finished_moving.disconnect(_on_finished_moving)
	if acting_unit.finished_acting.is_connected(_on_finished_acting):
		acting_unit.finished_acting.disconnect(_on_finished_acting)
	acting_unit.decision_director.finish_directive()


## Logic for determining if the current directive has been finished, and should run in its [end] method. The directive will automatically check if it is finished every time the unit executing it finishes moving or acting.
@abstract func check_if_finished() -> bool


func _on_finished_moving(_unit : Unit):
	if check_if_finished():
		end()


func _on_finished_acting(_unit : Unit):
	if check_if_finished():
		end()