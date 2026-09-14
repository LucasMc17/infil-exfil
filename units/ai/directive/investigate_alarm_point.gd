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

# TODO: There's a lot to come here. Units should not go straight for the last poc. they should instead nav into the room of last conflict. If no intruders are detected, then move to last poc. If they are blocked on the way there, consider it good enough and move to next action.  Also, last poc shouldn't wbe where they were stangin, but a 2-tile radius around the last place they saw a live friendly. Finally, if during any of these steps they reacquire the enemy, cancel all movement and shift back to combat/pursuit.