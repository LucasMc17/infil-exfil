class_name RandomPatrol
extends Directive

## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func begin(unit : EnemyUnit) -> void:
	super(unit)
	attack_skill = acting_unit.skill_machine.skills["EnemyAttack"]
	attack_skill.arm_as_enemy()
	var unit_valid_moves = Level.current.nav_map.get_all_valid_moves(unit.board_position, unit.max_movement_points)
	var move = unit_valid_moves.pick_random()

	unit.move("Run", move)


func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	else:
		acting_unit.forfeit_turn()


func _on_finished_acting(unit : EnemyUnit):
	# Unit found their target.
	super(unit)
	end()
	unit.decision_director.clear_queue()
	acting_unit.forfeit_turn()