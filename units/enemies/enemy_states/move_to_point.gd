extends UnitState

var end_point : Vector3

var speed := 1.0

var points := []

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	World.level.nav_map.do_debug_path(unit.tile_position, end_point)
	var path = World.level.nav_map.find_path(unit.tile_position, end_point)
	if unit.potential_moves.has(end_point):
		points = path
	else:
		points = path.slice(1, unit.max_movement + 1)


func physics_update(delta: float):
	unit.follow_path(delta, points, speed)


func exit():
	Events.enemy_action_ended.emit()