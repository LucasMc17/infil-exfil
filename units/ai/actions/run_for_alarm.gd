class_name RunForAlarmAction
extends Action

func begin(unit : EnemyUnit) -> void:
	DebugConsole.log('running for alarm')
	unit.action_director.finish_action()

func end(_unit : EnemyUnit) -> void:
	pass
