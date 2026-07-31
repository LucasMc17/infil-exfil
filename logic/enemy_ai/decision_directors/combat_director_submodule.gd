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


## Main function for deciding on a new combat directive
func choose_combat_directive() -> Directive:
	if !World.level.enemy_awareness.alarm_active and !World.level.enemy_awareness.alarm_runner:
		if Utilities.dice_roll(unit.alarm_run_chance):
			World.level.enemy_awareness.alarm_runner = unit
			return RunForAlarm.new()
		else:
			var friendlies_in_sight = awareness.friendlies_in_sight
			if !friendlies_in_sight.is_empty():
				return MoveAndAttack.new(friendlies_in_sight[0].friendly)
			return NoDirective.new()
	else:
		return NoDirective.new()


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
		
	