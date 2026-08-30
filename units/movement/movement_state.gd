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
var full_path : Array = []
## A copy of the above array for mutating as the unit removes points it has reached.
var path : Array = []
## Boolean representing whether the unit is currently between two points.
var is_between_points := false
## The point this unit would move to next if it was not blocked by another unit (for AI-controlled units only).
var ghost_point : Variant
## 
var first_step := true

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	ghost_point = null
	first_step = true
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
				ghost_point = point
				unit.temp_blocker = blocker
				if blocker is EnemyUnit:
					blocker.temp_blocking_path = temp_path
				break
			else:
				full_path.append(point)
		path = full_path.duplicate()
		unit.movement_points = 0
	elif ext.has('path'):
		full_path = path.duplicate()
		unit.movement_points -= path.size()
	else:
		DebugConsole.error('Must pass MovementState an end_point or a path array of points.')
	Level.current_level.movement_system.deactivate()


func physics_update(delta: float):
	# unit.follow_path(path_walk, delta, mps)
	# move towards the next point
	# if we reach it:
		# check for detection
		# If there is a next point:
			# turn toward the next point if one exists.
		# else:
			# if we have a ghost point:
				# turn towards it 
				# check for detection
			# then end the walk either way
	
	var update_captive_position = func() -> void:
		if unit.captive:
			unit.captive.position = unit._hostage_marker.global_position
			unit.captive.board_position = unit.board_position
			unit.captive.rotation.y = unit.rotation.y

	
	var handle_ghost_point = func() -> void:
		var direction = (ghost_point - unit.position).normalized()
		var angle = atan2(-direction.x, -direction.z)
		ghost_point = null

		if unit.rotation.y != angle:
			unit.rotation.y = angle
		# TODO: Long term, I think this should just force a detection of the blocking unit at this point. Right? I don't like having to await a physics frame.
		# TODO: Other todo. One thing that might also fix this is actually lerp the rotation for a few frames, checking for detection on each. Would also fix unit turning blindspots.
		unit.check_for_detection()
	

	var walk_to_next_point = func(next_pos : Vector3) -> void:
		unit.position = unit.position.move_toward(next_pos, mps * delta)
		# var direction = (next_pos - unit.position).normalized()
		# var angle = atan2(-direction.x, -direction.z)
		# if unit.rotation.y != angle:
		# 	unit.rotation.y = angle
		update_captive_position.call()
	

	var handle_arrival_at_point = func() -> void:
		unit.board_position = path.pop_front()
		unit.check_for_detection()
		if !path.is_empty():
			var next_point = NavigableGridMap.convert_grid_to_global_position(path[0])
			var direction = (next_point - unit.position).normalized()
			var angle = atan2(-direction.x, -direction.z)
			if unit.rotation.y != angle:
				unit.rotation.y = angle
			update_captive_position.call()
		else:
			if ghost_point:
				handle_ghost_point.call()
			unit.stop_moving()
	
	if path.is_empty():
		if ghost_point:
			handle_ghost_point.call()
		unit.stop_moving()
		return
	
	var next_global_pos = NavigableGridMap.convert_grid_to_global_position(path[0])

	if first_step:
		first_step = false
		var direction = (next_global_pos - unit.position).normalized()
		var angle = atan2(-direction.x, -direction.z)
		if unit.rotation.y != angle:
			unit.rotation.y = angle

	walk_to_next_point.call(next_global_pos)

	if unit.position == next_global_pos:
		handle_arrival_at_point.call()


func exit():
	path = []
	full_path = []
	ghost_point = null
	is_between_points = false
	first_step = true
	unit.refresh_valid_moves.call_deferred()
	unit.finished_moving.emit(unit)
	unit.is_moving = false
