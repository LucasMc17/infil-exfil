extends UnitState

var end_point : Vector3

var speed := 1.0

var points := []

var will_reach_endpoint := false

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	World.level.cell_highlighter.highlighted_cells = []
	World.level.nav_map.do_debug_path(unit.tile_position, end_point)
	var path = World.level.nav_map.find_path(unit.tile_position, end_point)
	if unit.potential_moves.has(end_point):
		will_reach_endpoint = true
		points = path
	else:
		will_reach_endpoint = false
		points = path.slice(1, unit.max_movement + 1)


func physics_update(delta: float):
	unit.follow_path(delta, points, speed)


# func exit():
# 	if unit is EnemyUnit:
# 		if unit.decision_director.current_directive is MoveToPoint and will_reach_endpoint:
# 			unit.decision_director.current_directive
# 		Events.enemy_turn_ended.emit()