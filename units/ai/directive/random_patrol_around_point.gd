class_name RandomPatrolAroundPoint
extends Directive

# TODO: More to do before this is implemented. It should pick a random point every  turn and go on indefinitely, only interrupted when the unit reacquires the enemy or has their directive queue reset by an outside influence, like the alarm coming off.

var point : Vector3i
var all_valid_moves : Array[Vector3i]

func _init(p : Vector3i) -> void:
	point = p


func begin(unit : EnemyUnit) -> void:
	super(unit)
	all_valid_moves = Level.current_level.nav_map.get_all_valid_moves(point, unit.max_movement_points)
	var unit_valid_moves = Level.current_level.nav_map.get_all_valid_moves(unit.board_position, unit.max_movement_points)
	var move = unit_valid_moves.filter(func (pos): return all_valid_moves.has(pos)).pick_random()

	unit.move("Run", move)


func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	end()
	acting_unit.forfeit_turn()