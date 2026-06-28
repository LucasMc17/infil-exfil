## An action state representing no specific action, the default state when no specific action is being performed.
class_name NoAction
extends State

## The unit performing this no-action.
@export var unit : Unit

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.debug_label.change_param('action_state', name)