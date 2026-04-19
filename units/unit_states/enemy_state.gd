class_name UnitState
extends State

@export var unit : Unit

func enter(previous_state, ext):
	super(previous_state, ext)
	unit.debug_label.change_param('state', name)