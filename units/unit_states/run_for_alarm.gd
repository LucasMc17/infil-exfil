class_name RunForAlarm
extends UnitState

func enter(previous_state, ext):
	super(previous_state, ext)
	transition.call_deferred('FinishedMoving')