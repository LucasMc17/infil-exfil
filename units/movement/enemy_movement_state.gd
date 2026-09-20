## Movement state specifically for enemies, as there are a lot of specific behaviors the movement state needs to take on when inititated by an AI system, instead of the player's decision making.
class_name EnemyMovementStates
extends MovementState

## The end point of the current movement, established when entering the state and used to create a path for navigation.
var end_point : Vector3
## Whether or not this unit should move to an exact point, or just into the vicinity of one.
var exact_point := true
## The radius to get within if the movement is not to an exact point.
var point_radius := 3

func enter(previous_state, ext) -> void:
	super(previous_state, ext)
	if ext.has('end_point'):
		var temp_path = Level.current_level.nav_map.find_path(unit.board_position, end_point, exact_point, point_radius).slice(0, unit.movement_points)
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
	else:
		DebugConsole.error('Must pass EnemyMovementState an end_point.')