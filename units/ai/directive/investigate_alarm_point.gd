## Navigate to a position where combatants were heard encountered, as announced over an alarm.
class_name InvestigateAlarmPoint
extends Directive

func begin(unit : EnemyUnit) -> void:
	super(unit)
	unit.move("Run", {"end_point": Level.current_level.alarm.alarm_point})


func _on_finished_moving(unit : EnemyUnit):
	super(unit)
	if acting_unit.board_position == Level.current_level.alarm.alarm_point:
		end()
	unit.forfeit_turn()


func cancel() -> void:
	Level.current_level.alarm.point_investigated = true
	super()


func end() -> void:
	Level.current_level.alarm.point_investigated = true
	super()