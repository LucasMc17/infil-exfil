## A submodule of the [DecisionDirectorModule] specifically for deciding what actions to take while in combat.
class_name CombatDirectorSubmodule
extends Resource

## The Unit for whom this director is making decisions.
var unit : EnemyUnit
## The awareness module for this director (and the unit)
var awareness : EnemyUnitAwarenessModule

func _init(u : EnemyUnit, a : EnemyUnitAwarenessModule) -> void:
	unit = u
	awareness = a


## Main function for deciding on a new combat directive. Returns a non-empty array of directives, which can be only one entry long.
func choose_combat_directive() -> Array[Directive]:
	# Run for the alarm if needed.
	if _decide_on_alarm_run():
		return [RunForAlarm.new()]
	else:
		if !awareness.friendlies_in_sight.is_empty():
			var target : FriendlyUnit = unit.awareness.suppression_target if unit.awareness.suppression_target else awareness.friendlies_in_sight[0].friendly
			return [MoveAndAttack.new(target)]
		elif !awareness.friendlies_out_of_sight.is_empty() and !awareness.has_pursued:
			var pursued = awareness.friendlies_out_of_sight[0]
			var result : Array[Directive] = [Pursue.new(pursued.friendly, pursued.last_known_position)]
			if !Level.current_level.alarm.active and !Level.current_level.enemy_awareness.alarm_runner:
				result.append(RunForAlarm.new())
			return result
		elif Level.current_level.alarm.active and !Level.current_level.alarm.point_investigated:
			return [InvestigateAlarmPoint.new()]
		else:
			return [NoDirective.new()]


func _decide_on_alarm_run() -> bool:
	if Level.current_level.alarm.active or Level.current_level.enemy_awareness.alarm_runner:
		return false
	if awareness.friendlies_in_sight.is_empty() and awareness.friendlies_out_of_sight.is_empty():
		return true
	if !awareness.friendlies_in_sight.is_empty():
		return Utilities.dice_roll(unit.alarm_run_chance)
	return false


# Lets get to basics here.
# No alert phase is finished in the eyes of an alerted unit until an alarm has sounded and ended. During combat or pursuit, they will continuously run checks to see if they should run for the alarm, unless one is already sounding, or if another unit is already running for the alarm. 
# If the unit has no more friendlies in sight, either because they incapacitated them all, or lost sight of them all, they will 100% run for the alarm next action as long as it is not sounding, and no one else is currently running for it.


# combat flow
# there is an alarm or someone running for the alarm:
# 	i can see enemies:
# 		I have a suppressed target:
# 			attack suppressed target
# 		I do not have a suppressed target:
# 			attack random target
# 	I can not see enemies:
# 		pursue
# 		I still cannot see enemies:
# 			search (follow nav beacons)
# there is no alarm or unit running for the alarm:
# 	dice roll passes:
# 		run for the alarm
# 	dice roll fails:
# 		do above combat flow
		
	