class_name Pursue
extends Directive

## The target of this attack.
var target : FriendlyUnit
## Whether or not the unit performing this directive has yet visited the last known position of the target friendly.
var visisted_last_seen := false
## The last seen position of the enemy.
var last_known_pos : Vector3i
## The attack skill the unit intends to use.
var attack_skill : EnemyAttack

func _init(t : FriendlyUnit, lkp : Vector3i) -> void:
	target = t
	last_known_pos = lkp


func begin(unit : EnemyUnit) -> void:
	super(unit)
	if !visisted_last_seen:
		acting_unit.movement_machine.current_state.transition("Run", { "end_point": last_known_pos })


func _on_finished_moving(unit : Unit):
	super(unit)
	if !visisted_last_seen:
		if acting_unit.board_position == last_known_pos:
			visisted_last_seen = true
		acting_unit.forfeit_turn()