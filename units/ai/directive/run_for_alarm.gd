class_name RunForAlarm
extends Directive

var _alarm_point : Variant = null

func begin(unit : EnemyUnit) -> void:
	super(unit)
	_alarm_point = null
	DebugConsole.log('Enemy Runs for Alarm', 2)
	_alarm_point = World.level.nav_map.get_closest_point(acting_unit.tile_position, World.level.nav_map.alarms.keys())
	if !_alarm_point:
		acting_unit.forfeit_turn.call_deferred()
		end()
	else:
		acting_unit.movement_machine.current_state.transition("Run", { "end_point": _alarm_point})


func _on_finished_moving(_unit : Unit):
	if acting_unit.tile_position as Vector3i == _alarm_point:
		pass
	else:
		acting_unit.forfeit_turn()


func check_if_finished() -> bool:
	return false
