## A State for use as a direct child of a StateMachine.[br]
## The StateMachine defers it's `_process`, `_physics_process`, and `_input` behavior to that of its currently active state.[br]
## Will frequently be extended into a more specific form for use in particular contexts, i.e. PlayerState, NPCState, UIState, etc.
class_name State
extends Node

## The signal emitted when the activated state transitions to another, sibling state.
signal transitioned(new_state_name: StringName, ext : Dictionary)

## Whether or not the state is currently active
var active := false

## Transition from this state to another sibling state within the parent StateMachine.
func transition(new_state_name : StringName, ext := {}):
	transitioned.emit(new_state_name, ext)


## Called when entering this state.
func enter(_previous_state : State, ext : Dictionary):
	active = true
	for key in ext:
		var value = ext[key]
		if key in self:
			self[key] = value


## Called when exiting a state, just before entering the next state.
func exit():
	active = false


## The proxy update function, running every frame whenever the State is activated.
func update(_delta: float):
	pass


## The proxy physics update function, running every frame whenever the State is activated.
func physics_update(_delta: float):
	pass


## The proxy input function, running whenever an input is received and the State is activated.
func input(_event: InputEvent):
	pass


## The proxy unhandled input function, running whenever an input is received, not handled by earlier UI elements, and the State is activated.
func unhandled_input(_event: InputEvent):
	pass
