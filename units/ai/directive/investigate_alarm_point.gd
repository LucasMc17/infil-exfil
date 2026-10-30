## Navigate to a position where combatants were heard encountered, as announced over an alarm.
class_name InvestigateAlarmPoint
extends Directive

var encountered_friendlies := false
## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func begin(unit : EnemyUnit) -> void:
	super(unit)
	attack_skill = acting_unit.skill_machine.skills["EnemyAttack"]
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	else:
		unit.move("Run", Level.current.alarm.alarm_point.position, false)


func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	# TODO: This is a pretty good example of why we need a better system for determining when the unit has simply finished moving and when they have fully arrived at their destination. This is the only action so far which uses the inexact movement system, and it works, but the unit will simply wait until they can finish the movement before considering the action complete, since the directive only knows the movement is fully complete when the unit's exact position is the exact alarm point. We could check if they are within a certain distance, but that's ugly. We really need a separate handler, something like "unit arrived at desintation", in addition to "unit finished moving". Then the movement state itself can determing if this should be emitted by comparing the unit's final position to the last point on the planned path.
	elif arrived:
		end()
		unit.forfeit_turn()
	else:
		unit.forfeit_turn()

func _on_finished_acting(unit : EnemyUnit):
	# Unit found friendlies.
	super(unit)
	end()
	acting_unit.listening = false
	acting_unit.forfeit_turn()


func cancel() -> void:
	super()
	acting_unit.decision_director.current_directive = null
	acting_unit.decision_director.current_directive_queue.clear()


func end() -> void:
	Level.current.alarm.point_investigated = true
	super()


func _on_encountering_friendly(_friendly : FriendlyUnit) -> void:
	encountered_friendlies = true
	acting_unit.stop_moving()

# TODO: There's a lot to come here. Units should not go straight for the last poc. they should instead nav into the room of last conflict. If no intruders are detected, then move to last poc. If they are blocked on the way there, consider it good enough and move to next action.  Also, last poc shouldn't wbe where they were stangin, but a 2-tile radius around the last place they saw a live friendly. Finally, if during any of these steps they reacquire the enemy, cancel all movement and shift back to combat/pursuit.