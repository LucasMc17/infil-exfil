class_name NoDirective
extends Directive

func begin(unit : EnemyUnit) -> void:
	super(unit)
	DebugConsole.log("Enemy takes no action")
	unit.action_machine.current_state.transition("NoAction")


func check_if_finished() -> bool:
	return true