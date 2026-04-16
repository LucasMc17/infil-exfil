extends EnemyState

var end_point : Vector3

var points := []

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)


func take_turn():
	World.level.nav_map.do_debug_path(unit.tile_position, end_point)
	var path = World.level.nav_map.find_path(unit.tile_position, end_point)
	if unit.potential_moves.has(end_point):
		points = path
	else:
		points = path.slice(1, unit.max_movement + 1)


func physics_update(_delta: float):
	if points.is_empty():
		return
	unit.tile_position = lerp(unit.tile_position, points[0], 0.15)
	unit.snap_to_position()
	if unit.tile_position.distance_to(points[0]) < 0.01:
		unit.tile_position = points[0]
		unit.snap_to_position()
		points.pop_front()
		unit.vision_zone.queue_vision_test()