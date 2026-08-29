## Move towards a known enemy position (if needed) and attack them. Used primarily by units who are already alarmed and have enemies currently in sight.
class_name MoveAndAttack
extends Directive

## The target of this attack.
var target : FriendlyUnit
## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func _init(t : FriendlyUnit) -> void:
	target = t


func begin(unit : EnemyUnit) -> void:
	super(unit)
	attack_skill = acting_unit.skill_machine.skills["EnemyAttack"]
	if !unit.temp_blocking_path.is_empty():
		respect_nudge()
	else:
		attack_skill.arm_as_enemy()
		if attack_skill.potential_targets.has(target):
			attack_skill.use({ "target": target })
		else:
			attack_skill.disarm_as_enemy()
			var valid_move = Level.current_level.nav_map.probe_for_viable_move(acting_unit.position, acting_unit.movement_points, _filter_move)
			if valid_move:
				# TODO: need a cleaner api for initiating movement.
				acting_unit.movement_machine.current_state.transition('Run', { "end_point": valid_move })

			else:
				acting_unit.movement_machine.current_state.transition('Run', { "end_point": target.board_position })


func respect_nudge() -> void:
	var valid_move = Level.current_level.nav_map.probe_for_viable_move(acting_unit.position, acting_unit.movement_points, _filter_move, acting_unit.temp_blocking_path)
	if valid_move:
		acting_unit.movement_machine.current_state.transition('Walk', { "end_point": valid_move })
	else:
		acting_unit.forfeit_turn.call_deferred()
		end()


func _on_finished_acting(_unit : Unit):
	super(acting_unit)
	end()
	acting_unit.forfeit_turn()


func _on_finished_moving(_unit : Unit):
	super(acting_unit)
	attack_skill.arm_as_enemy()
	if attack_skill.potential_targets.has(target):
		attack_skill.use({ "target": target })
	else:
		end()
		attack_skill.disarm_as_enemy()
		acting_unit.forfeit_turn()


func _filter_move(move : Vector3) -> bool:
	return attack_skill.judge_position(move, target)