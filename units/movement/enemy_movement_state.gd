## Movement state specifically for enemies, as there are a lot of specific behaviors the movement state needs to take on when inititated by an AI system, instead of the player's decision making.
class_name EnemyMovementStates
extends MovementState

## The full path this unit intends to walk to get to their destination, regardless of whether they can cover that much ground in a single move.
var full_intended_path : Array = []
## The end point of the current movement, established when entering the state and used to create a path for navigation.
var end_point : Vector3
## Whether or not this unit should move to an exact point, or just into the vicinity of one.
var exact_point := true
## The radius to get within if the movement is not to an exact point.
var point_radius := 3
## Whether or not the enemy unit has been in the player's site during this movement, regardless of whether they are currently in the player's site.
var been_sighted := false

func enter(previous_state, ext) -> void:
	super(previous_state, ext)
	if unit.awareness.player_aware:
		been_sighted = true
		Level.current.level_camera.fix_to_actor(unit)
	if ext.has('end_point'):
		full_intended_path = Level.current.nav_map.find_path(unit.board_position, end_point, exact_point, point_radius)
		var temp_path = full_intended_path.slice(0, unit.movement_points)
		for point in temp_path:
			var blocker = Level.current.nav_map.get_point_occupier(point)
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


func _on_arrival_at_point() -> void:
	await get_tree().physics_frame
	Level.test_player_awareness(unit)
	if unit.awareness.player_aware:
		Level.current.level_camera.fix_to_actor(unit)
		been_sighted = true
	else:
		Level.current.level_camera.unfix()


func _move_toward_next_point(next_pos : Vector3, delta : float) -> void:
	if !unit.awareness.player_aware and !been_sighted:
		unit.position = next_pos
	else:
		super(next_pos, delta)


func exit():
	super()
	been_sighted = false
	unit.finished_moving.emit(unit, full_intended_path.is_empty() or Vector3(unit.board_position) == full_intended_path[-1])