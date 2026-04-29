class_name RunForAlarm
extends Directive

func begin(unit : EnemyUnit) -> void:
	super(unit)
	DebugConsole.log('running for alarm')
	acting_unit.forfeit_turn.call_deferred()
	end()


func check_if_finished() -> bool:
	return true
