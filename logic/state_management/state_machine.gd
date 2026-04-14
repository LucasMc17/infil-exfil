class_name StateMachine
extends Node
## A node for managing the state of an actor and localizing state logic to sub modules.

## Whether the state machine is currently disabled and cannot switch states.
@export var disabled := false
## The state currently active from the StateMachine.
@export var current_state : State

## A full list of the States (direct children of this node) listed by their names.
var states: Dictionary[String, State] = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transitioned.connect(_on_child_transitioned)
		else:
			push_warning("State machine contains incompatible child node")
	
	await owner.ready
	# NOTE: Commented this out to avoid issues when initializing enemy state from action queue. May need to bring back.
	current_state.enter(null, {})


## Lock the state machine.
func lock():
	disabled = true


## Unlock the state machine.
func unlock():
	disabled = false


func _input(event):
	current_state.input(event)


func _process(delta):
	current_state.update(delta)


func _physics_process(delta):
	current_state.physics_update(delta)


## Event listener for when the current state transitions to another sibling state.
func _on_child_transitioned(new_state_name: StringName, ext : Dictionary):
	if !disabled:
		var new_state = states.get(new_state_name)
		if new_state != null and new_state != current_state:
			current_state.exit()
			new_state.enter(current_state, ext)
			current_state = new_state