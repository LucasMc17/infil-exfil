class_name FinishedMoving
extends UnitState

func enter(previous_state, ext):
	super(previous_state, ext)
	Events.enemy_finished_moving.emit(unit)