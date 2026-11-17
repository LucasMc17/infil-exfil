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
	# TODO: Long term, we might consider a separate handler for arriving at the destination. I need more testing to be sure, but I think this will struggle with making that determination, since this movement is inexact. We could get within 3 moves of the destiantion, which this state considers good enough, but the arrived bool will still be false because it is determined by comparing the unit's exact position to their exact intended destination. Test this to confirm, I could be wrong.
	elif arrived:
		end()
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

# TODO: There's a lot to come here. Units should not go straight for the last poc. they should instead nav into the room of last conflict. If no intruders are detected, then move to last poc. If they are blocked on the way there, consider it good enough and move to next action.  Also, last poc shouldn't be where they were standing, but a 2-tile radius around the last place they saw a live friendly. Finally, if during any of these steps they reacquire the enemy, cancel all movement and shift back to combat/pursuit.