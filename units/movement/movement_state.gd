class_name MovementState
extends State

@export var unit : Unit

@export var cost := 1

@export var mps := 1.0

var end_point : Vector3

var points := []

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	unit.debug_label.change_param('movement_state', name)
	unit.movement_points -= cost
	unit.started_moving.emit(unit)
	var path = World.level.nav_map.find_path(unit.tile_position, end_point)
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