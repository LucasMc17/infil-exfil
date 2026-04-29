class_name NoDirective
extends Directive

func begin(unit : EnemyUnit) -> void:
	super(unit)
	DebugConsole.log("Enemy takes no action")
	acting_unit.forfeit_turn.call_deferred()
	end()


func check_if_finished() -> bool:
	return true