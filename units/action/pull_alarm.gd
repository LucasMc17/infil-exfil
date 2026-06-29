# TODO: There's a lot to work on with these action states since they have been largely outmoded by the [Skill] system. I think these specific action states will be replaced by only two, a no action state and an action state. The action state will take in a skill and know how to change unit behavior based on it. This pull alarm state for example will be replaced with a skill.
## An action state representing pulling an alarm, for use by an [EnemyUnit].
class_name PullAlarm
extends ActionState

## A temporary variable setting a timer to delay the unit's return to a no-action state. In later builds, I believe this will be based on the length of the action's associated animation.
var temp_timer := 1.0

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	DebugConsole.log("Unit pulling alarm", 2)
	Events.alarm_raised.emit(null, unit)


func update(delta: float):
	temp_timer -= delta
	if temp_timer <= 0:
		transition('NoAction')