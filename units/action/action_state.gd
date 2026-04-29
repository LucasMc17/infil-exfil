class_name ActionState
extends State

@export var unit : Unit

@export var cost := 1

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.started_acting.emit(unit)


func exit():
	super()
	unit.finished_acting.emit(unit)