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
	attack_skill.arm_as_enemy()
	if attack_skill.potential_targets.has(target):
		attack_skill.use({ "target": target })
	else:
		attack_skill.disarm_as_enemy()
		var valid_move = Level.current_level.nav_map.probe_for_viable_move(acting_unit.position, acting_unit.movement_points, _filter_move)
		if valid_move:
			acting_unit.movement_machine.current_state.transition('Run', { "end_point": valid_move })

		else:
			# NOTE: Should this be a built in function of the nav map?
			# TODO: Used to have to target a neighbor of the target. not anymore. update this.
			var neighbors : Array[Vector3i] = [
				target.board_position + Vector3i(1, 0, 0),
				target.board_position + Vector3i(-1, 0, 0),
				target.board_position + Vector3i(0, 0, 1),
				target.board_position + Vector3i(0, 0, -1)
			]
			var target_point = Level.current_level.nav_map.get_closest_point(acting_unit.board_position, neighbors)
			if target_point:
				acting_unit.movement_machine.current_state.transition('Run', { "end_point": target_point })
			else:
				end()
				acting_unit.forfeit_turn.call_deferred()


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

# TODO: This doesn't test for line of sight yet
func _filter_move(move : Vector3) -> bool:
	return move.distance_to(target.board_position) <= attack_skill.effective_range
