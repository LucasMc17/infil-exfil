## An abstract, extended [State] representing a unit's possible modes of movement, for use with a [MovementMachine].
@abstract class_name MovementState
extends State

## The unit this state corresponds to.
@export var unit : Unit
## The speed at which this movment state moves the unit, in meters per second.
@export var mps := 1.0

## An array of points along which the unit will move to reach the [end_point]
var full_path : Array = []
## A copy of the above array for mutating as the unit removes points it has reached.
var path : Array = []
## Boolean representing whether the unit is currently between two points.
var is_between_points := false
## The point this unit would move to next if it was not blocked by another unit (for AI-controlled units only).
var ghost_point : Variant
## True if the unit is just beginning to move.
var first_step := true

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	ghost_point = null
	first_step = true
	unit.started_moving.emit(unit)


## Internal function for handling the unit arriving at a point, not necessarily the final destination of the current movement. Custom behavior is typically accomplished by extending [_on_arrival_at_point], and NOT this function. However, this function can still be overridden if needed.
func _arrive_at_point() -> void:
	unit.board_position = path.pop_front()
	unit.check_for_detection()
	if !path.is_empty():
		var next_point = NavigableGridMap.convert_grid_to_global_position(path[0])
		var direction = (next_point - unit.position).normalized()
		var angle = atan2(-direction.x, -direction.z)
		if unit.rotation.y != angle:
			unit.rotation.y = angle
		_update_captive_position()
	else:
		if ghost_point:
			_handle_ghost_point()
		unit.stop_moving()
	_on_arrival_at_point()
	Events.unit_moved.emit()


## Internal function for updating the position of the unit's captive, if they have one.
func _update_captive_position() -> void:
		if unit.captive:
			unit.captive.position = unit._hostage_marker.global_position
			unit.captive.board_position = unit.board_position
			unit.captive.rotation.y = unit.rotation.y


## Internal function for handling the event of a 'ghost point' (the next space the unit intended to enter which was unexpectedly occupied by a previously unseen unit. Only relevant for AI-controlled units).
func _handle_ghost_point() -> void:
		var direction = (ghost_point - unit.position).normalized()
		var angle = atan2(-direction.x, -direction.z)
		ghost_point = null

		if unit.rotation.y != angle:
			unit.rotation.y = angle
		# TODO: Eventually we will want to actually lerp the rotation for a few frames, checking for detection on each. Would also fix unit turning blindspots.
		unit.check_for_detection()


## Extensible function for moving towards the next point. By default, smoothly lerps them towards the next point, but can be extended with custom behavior.
func _move_toward_next_point(next_pos : Vector3, delta : float) -> void:
	unit.position = unit.position.move_toward(next_pos, mps * delta)
	_update_captive_position()


## Lifecycle hook which runs when the unit arrives at a point, to be extended by inheriting scripts.
func _on_arrival_at_point() -> void:
	pass


func physics_update(delta: float):
	if path.is_empty():
		if ghost_point:
			_handle_ghost_point()
		unit.stop_moving()
		return
	
	var next_global_pos = NavigableGridMap.convert_grid_to_global_position(path[0])

	if first_step:
		first_step = false
		var direction = (next_global_pos - unit.position).normalized()
		var angle = atan2(-direction.x, -direction.z)
		if unit.rotation.y != angle:
			unit.rotation.y = angle

	_move_toward_next_point(next_global_pos, delta)

	if unit.position == next_global_pos:
		_arrive_at_point()


func exit():
	path = []
	full_path = []
	ghost_point = null
	is_between_points = false
	first_step = true
	unit.refresh_valid_moves.call_deferred()
	unit.is_moving = false
