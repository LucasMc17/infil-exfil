## An extended [State] representing a unit's possible modes of movement, for use with a [MovementMachine].
class_name MovementState
extends State

## The unit this state corresponds to.
@export var unit : Unit
## The speed at which this movment state moves the unit, in meters per second.
@export var mps := 1.0

## The end point of the current movement, established when entering the state and used to create a path for navigation.
var end_point : Vector3
## An array of points along which the unit will move to reach the [end_point]
var path := []

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	if unit is FriendlyUnit:
		unit.is_moving = true
		Events.skill_disarmed.emit()
	unit.debug_label.change_param('movement_state', name)
	unit.started_moving.emit(unit)
	if ext.has('end_point'):
		# somewhere around here is where we should start testing for unit blocking.
		var temp_path = Level.current_level.nav_map.find_path(unit.board_position, end_point).slice(0, unit.movement_points)
		for point in temp_path:
			if Level.current_level.nav_map.get_point_occupier(point):
				break
			else:
				path.append(point)
		unit.movement_points = 0
	elif ext.has('path'):
		unit.movement_points -= path.size()
	else:
		DebugConsole.error('Must pass MovementState an end_point or a path array of points.')
	Level.current_level.movement_system.deactivate()


func physics_update(delta: float):
	unit.follow_path(delta, path, mps)


func exit():
	unit.refresh_valid_moves.call_deferred()
	unit.finished_moving.emit(unit)
	unit.is_moving = false
