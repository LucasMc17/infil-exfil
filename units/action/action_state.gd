## An extended [State] representing a unit's possible actions, for use with an [ActionMachine].
class_name ActionState
extends State

## The unit this action state corresponds to.
@export var unit : Unit

## The name of the skill to use, for fetching the specific instance from the unit's skill list.
var skill_name := ""
## The skill the unit is using when in this action state.
var skill : Skill
## The timer keeping track of how long it has been since this action was triggered.
var timer := 1.0

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	timer = skill.time_to_perform
	unit.debug_label.change_param('action_state', name)
	unit.started_acting.emit(unit)


func update(delta: float):
	timer -= delta
	print(timer)
	if timer <= 0.0:
		transition("NoAction")


func exit():
	super()
	timer = 1.0
	skill = null
	unit.finished_acting.emit(unit)