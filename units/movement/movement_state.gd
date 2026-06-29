## An extended [State] representing a unit's possible modes of movement, for use with a [MovementMachine].
class_name MovementState
extends State

## The unit this state corresponds to.
@export var unit : Unit
## The cost in movement points of entering this movement state.
@export var cost := 1
## The speed at which this movment state moves the unit, in meters per second.
@export var mps := 1.0

## The end point of the current movement, established when entering the state and used to create a path for navigation.
var end_point : Vector3
## An array of points along which the unit will move to reach the [end_point]
var points := []

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	if unit is FriendlyUnit:
		Events.skill_disarmed.emit()
	unit.debug_label.change_param('movement_state', name)
	unit.movement_points -= cost
	unit.started_moving.emit(unit)
	var path = World.level.nav_map.find_path(unit.actual_position, end_point)
	if unit.potential_moves.has(end_point):
		points = path
	else:
		points = path.slice(1, unit.max_movement + 1)
	unit.refresh_valid_moves.call_deferred()


func physics_update(delta: float):
	unit.follow_path(delta, points, mps)


func exit():
	unit.refresh_valid_moves.call_deferred()
	unit.finished_moving.emit(unit)