extends EnemyState

var end_point : Vector3

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	print('entering move to point state: ', end_point)


func take_turn():
	World.level.nav_map.do_debug_path(unit.tile_position, end_point)
	var path = World.level.nav_map.find_path(unit.tile_position, end_point)
	if unit.potential_moves.has(end_point):
		unit.tile_position = end_point
		unit.snap_to_position()
	else:
		unit.tile_position = path[unit.max_movement]
		unit.snap_to_position()
	print(path)
	print('Taking turn')