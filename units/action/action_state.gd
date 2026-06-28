## An extended [State] representing a unit's possible actions, for use with an [ActionMachine].
class_name ActionState
extends State

## The unit this action state corresponds to.
@export var unit : Unit

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.debug_label.change_param('action_state', name)
	unit.started_acting.emit(unit)


func exit():
	super()
	unit.finished_acting.emit(unit)