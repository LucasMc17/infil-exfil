## A movement state representing no specific movement, the default state when the unit is not moving.
class_name NoMovement
extends State

## The unit performing this no-movement.
@export var unit : Unit

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.debug_label.change_param('movement_state', name)