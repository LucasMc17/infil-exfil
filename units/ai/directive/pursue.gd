class_name Pursue
extends Directive

# TODO : Noticed a bug here. Two units pursued the same friendly, ended up at the same dead end. One of them was at the end, unable to leave, because the other was behind blocking the only path out, and was still in pursuit. Enemies should safely exit pursuit when no nav path is possible. OR there should be a system for noticing when two units are blocking each other and nudge one of them, even if the directive they are in does not have a nudge func.

## The target of this attack.
var target : FriendlyUnit
## Whether or not the unit performing this directive has yet visited the last known position of the target friendly.
var visisted_last_seen := false
## The last seen position of the enem/y.
var last_known_pos : Vector3i
## Boolean tracking whether or not the pursuit path has already been calculated.
var _is_pursuit_path_set := false
## The path this enemy will follow in pursuit if they don't reacquire the friendly at their last known position.
var pursuit_path : Array[Vector3i] = []
## The index of the pursuit path which this unit is moving to as part of the pursuit.
var pursuit_index := 0
## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func _init(t : FriendlyUnit, lkp : Vector3i) -> void:
	target = t
	last_known_pos = lkp


func begin(unit : EnemyUnit) -> void:
	super(unit)
	unit.awareness.has_pursued = true
	if !_is_pursuit_path_set:
		pursuit_path = Level.current_level.get_likely_path(acting_unit.position, last_known_pos)
		_is_pursuit_path_set = true
	attack_skill = acting_unit.skill_machine.skills["EnemyAttack"]
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	elif !visisted_last_seen:
		acting_unit.move("Run", last_known_pos)
	else:
		acting_unit.move("Run", pursuit_path[pursuit_index])


## NOTE: We have a very interesting bug here. Units only need to see a fraction of a friendly's vision points to consider them seen, but they need to see center mass to target them. This leads to situations where an enemy pursues a friendly, sees them, then stops short (because of the first_sighting consideration in the see_friendlies func in unit awareness) but doesn't attack, which is very confusing for the player. Two possible solutions: Add a new vision point at center mass which is required to be visible to see a unit and retarget all skill targeting against this point, OR change skills to tap into the vision check func and only conisder an enemy targetable if they pass the visibility check. I lean towards the second option, but it has ramifications on how the player's skills will work too.
## See bug_evidence no. 2 for a picture of a unit who has just stopped short while seeing the unit in the foreground but without being able to attack
func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	attack_skill.arm_as_enemy()
	if !attack_skill.potential_targets.is_empty():
		attack_skill.use({ "target": attack_skill.potential_targets[0] })
	elif !visisted_last_seen:
		if acting_unit.board_position == last_known_pos:
			visisted_last_seen = true
			if !pursuit_path:
				end()
				# acting_unit.awareness.alert()
		acting_unit.forfeit_turn()
	else:
		var target_position = pursuit_path[pursuit_index]
		if acting_unit.board_position == target_position:
			pursuit_index += 1
			if pursuit_index >= pursuit_path.size():
				end()
				# acting_unit.awareness.alert()
		acting_unit.forfeit_turn()


func _on_finished_acting(unit : EnemyUnit):
	# Unit found their target, clear the planned alarm run.
	super(unit)
	end()
	unit.decision_director.clear_queue()
	acting_unit.forfeit_turn()
