class_name NoAction
extends Action

func begin(unit : EnemyUnit) -> void:
	DebugConsole.log("Enemy takes no action")
	unit.action_director.finish_action()

func end(_unit : EnemyUnit) -> void:
	pass