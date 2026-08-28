## An extended [State] representing a unit's possible modes of movement, for use with a [MovementMachine].
class_name MovementState
extends State

## Class representing information about a path which the unit is currently walking.
class PathWalk:
	## An array of points along which the unit will move to reach the [end_point]
	var full_path : Array = []
	## A copy of the above array for mutating as the unit removes points it has reached.
	var path : Array = []
	## Boolean representing whether the unit is currently between two points.
	var is_between_points := false
	## The point this unit would move to next if it was not blocked by another unit (for AI-controlled units only).
	var ghost_point : Variant

	func _init(p : Array, gp = null) -> void:
		full_path = p
		path = p.duplicate()
		ghost_point = gp


## The unit this state corresponds to.
@export var unit : Unit
## The speed at which this movment state moves the unit, in meters per second.
@export var mps := 1.0

## The end point of the current movement, established when entering the state and used to create a path for navigation.
var end_point : Vector3
## An array of points along which the unit will move to reach the [end_point]
var path := []

var path_walk : PathWalk

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	var gp = null
	if unit is FriendlyUnit:
		unit.is_moving = true
		Events.skill_disarmed.emit()
	unit.debug_label.change_param('movement_state', name)
	unit.started_moving.emit(unit)
	if ext.has('end_point'):
		# If this is called via the end_point method, the state was entered by an AI controller working towards moving the unit to an ultimate point, as opposed to by a player planning a specific route. Hence, everything in this if statement is only relative to AI controlled units.
		# NOTE: For the above reason, should we consider a unique enemy movement state, separate from player movement?
		var temp_path = Level.current_level.nav_map.find_path(unit.board_position, end_point).slice(0, unit.movement_points)
		for point in temp_path:
			var blocker = Level.current_level.nav_map.get_point_occupier(point)
			if blocker:
				gp = point
				unit.temp_blocker = blocker
				if blocker is EnemyUnit:
					blocker.temp_blocking_path = temp_path
				break
			else:
				path.append(point)
		unit.movement_points = 0
	elif ext.has('path'):
		unit.movement_points -= path.size()
	else:
		DebugConsole.error('Must pass MovementState an end_point or a path array of points.')
	path_walk = PathWalk.new(path, gp)
	Level.current_level.movement_system.deactivate()


func physics_update(delta: float):
	unit.follow_path(path_walk, delta, mps)


func exit():
	path = []
	path_walk = null
	unit.refresh_valid_moves.call_deferred()
	unit.finished_moving.emit(unit)
	unit.is_moving = false
