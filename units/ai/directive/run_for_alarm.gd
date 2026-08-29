## A directive representing a dash for the alarm. Is considered finished when there is an active alarm, whether or not this specific unit pulled it.
class_name RunForAlarm
extends Directive

## The position of the alarm the unit is running for.
var _alarm_point : Variant = null

func begin(unit : EnemyUnit) -> void:
	super(unit)
	_alarm_point = null
	DebugConsole.log('Enemy Runs for Alarm', 2)
	_alarm_point = Level.current_level.nav_map.get_closest_point(acting_unit.board_position, Level.current_level.nav_map.alarms.keys())
	if !_alarm_point:
		acting_unit.forfeit_turn.call_deferred()
		end()
	else:
		acting_unit.move("Run", { "end_point": _alarm_point})


func _on_finished_moving(_unit : Unit):
	super(acting_unit)
	if acting_unit.board_position == _alarm_point:
		var pull_alarm : PullAlarm = acting_unit.skill_machine.skills["PullAlarm"]
		pull_alarm.use()
	else:
		acting_unit.forfeit_turn()


func _on_finished_acting(_unit : Unit):
	super(acting_unit)
	end()
	acting_unit.forfeit_turn()
