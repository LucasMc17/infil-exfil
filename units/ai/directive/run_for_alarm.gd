## A directive representing a dash for the alarm. Is considered finished when there is an active alarm, whether or not this specific unit pulled it.
class_name RunForAlarm
extends Directive

## The position of the alarm the unit is running for.
var _alarm_point : Variant = null

func begin(unit : EnemyUnit) -> void:
	super(unit)
	_alarm_point = null
	DebugConsole.log('Enemy Runs for Alarm', 2)
	_alarm_point = World.level.nav_map.get_closest_point(acting_unit.actual_position, World.level.nav_map.alarms.keys())
	if !_alarm_point:
		acting_unit.forfeit_turn.call_deferred()
		end()
	else:
		acting_unit.movement_machine.current_state.transition("Run", { "end_point": _alarm_point})


func _on_finished_moving(_unit : Unit):
	if acting_unit.actual_position == _alarm_point:
		acting_unit.action_machine.current_state.transition("PullAlarm")
	acting_unit.forfeit_turn()


func check_if_finished() -> bool:
	return World.level.enemy_awareness.alarm_active
