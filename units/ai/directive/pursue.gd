class_name Pursue
extends Directive

# TODO: A lot more to do here. They need to be constantly checking for reacquired targets and switching back to combat directives if found. Also: We need to start thinking about a better solution for units blocking spaces. It's good that a unit can block another's path and that no two units can stand in the same spot. However, if a unit's destination is blocked, we cannot currently generate a path to get even close to it, so the unit gives up on moving entirely. This is no good. We need two things which may be connected to one another:
	# 1. A way to tell a unit to move towards a point and perhaps give up only when getting as close to it as possible.
	# 2. The map of blocked positions shouldn't stop astar from pathing through them. We need a way to generate a path, and if the only path is through other units, flag it as not fully transversible and tell the unit to move to the last unblocked point. I think weights will be important here. However I also see this raising issues with friendly unit movement projections, as even with high weights, if there are no alternative paths to a point the system will let units move through them. Ugh.

## The target of this attack.
var target : FriendlyUnit
## Whether or not the unit performing this directive has yet visited the last known position of the target friendly.
var visisted_last_seen := false
## The last seen position of the enem/y.
var last_known_pos : Vector3i
## The path this enemy will follow in pursuit if they don't reacquire the friendly at their last known position.
var pursuit_path : Array[Vector3i] = []
## The index of the pursuit path which this unit is moving to as part of the pursuit.
var pursuit_index := 0
## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func _init(t : FriendlyUnit, lkp : Vector3i) -> void:
	target = t
	last_known_pos = lkp
	print(pursuit_path)


func begin(unit : EnemyUnit) -> void:
	super(unit)
	if !pursuit_path:
		pursuit_path = World.level.get_likely_path_v2(acting_unit.position, last_known_pos)
	attack_skill = acting_unit.skill_machine.skills["EnemyAttack"]
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	elif !visisted_last_seen:
		acting_unit.movement_machine.current_state.transition("Run", { "end_point": last_known_pos })
	else:
		acting_unit.movement_machine.current_state.transition("Run", { "end_point": pursuit_path[pursuit_index] })


func _on_finished_moving(unit : Unit):
	super(unit)
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	elif !visisted_last_seen:
		if acting_unit.board_position == last_known_pos:
			visisted_last_seen = true
		acting_unit.forfeit_turn()
	else:
		var target_position = pursuit_path[pursuit_index]
		if acting_unit.board_position == target_position:
			pursuit_index += 1
			if pursuit_index >= pursuit_path.size():
				end()
				acting_unit.awareness.alert()
		acting_unit.forfeit_turn()


func _on_finished_acting(unit : Unit):
	super(unit)
	end()
	acting_unit.forfeit_turn()
