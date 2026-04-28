class_name RunForAlarmAction
extends Action

func begin(unit : EnemyUnit) -> void:
	super(unit)
	# unit.state_machine.current_state.transition("RunForAlarm")
	DebugConsole.log('running for alarm')


func check_if_finished() -> bool:
	return true
