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


## To be called when the unit begins fulfilling this directive and has been nudged by an allied unit (when receiving the signal from another unit that they are blocking their path).[br]
## This is primarily for use with directives that do not necessarily cause the unit to move every turn. If a directive demands a unit move, they should not use this flag and instead prioritize the movement they were already going to perform.[br]
## By default this function is not invoked anywhere by the directive script. If a directive should respect nudges, it must be invoked like so:
	## ```
	## func begin(unit : EnemyUnit) -> void:
	## 	super(unit)
	## 	if !unit.temp_blocking_path.is_empty():
	## 		respect_nudge()
	## 	else:
	## 		// other code...
	## ```
func respect_nudge() -> void:
	pass


func _on_finished_moving(_unit : Unit):
	pass


func _on_finished_acting(_unit : Unit):
	pass