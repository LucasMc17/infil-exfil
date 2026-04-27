class_name NoAction
extends Action

func begin(unit : EnemyUnit) -> void:
	super(unit)
	DebugConsole.log("Enemy takes no action")
	unit.state_machine.current_state.transition("NoAction")

func check_if_finished() -> bool:
	return true