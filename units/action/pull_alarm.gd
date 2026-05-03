class_name PullAlarm
extends ActionState

var temp_timer := 1.0

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	DebugConsole.log("Unit pulling alarm", 2)


func update(delta: float):
	temp_timer -= delta
	if temp_timer <= 0:
		transition('NoAction')