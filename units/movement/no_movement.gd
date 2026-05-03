class_name NoMovement
extends State

@export var unit : Unit

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.debug_label.change_param('movement_state', name)