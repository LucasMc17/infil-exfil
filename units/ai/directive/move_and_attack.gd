## Move towards a known enemy position (if needed) and attack them. Used primarily by units who are already alarmed and have enemies currently in sight.
class_name Attack
extends Directive

## The target of this attack.
var target : FriendlyUnit

func _init(t : FriendlyUnit) -> void:
	target = t


func begin(unit : EnemyUnit) -> void:
	super(unit)
	# TODO: There is no actual logic about movement here yet. Will have to set that up soon.
	acting_unit.use_skill("EnemyAttack", { "target": target})
	# acting_unit.available_skills["EnemyAttack"].enemy_use()


func _on_finished_acting(_unit : Unit):
	super(acting_unit)
	end()
	acting_unit.forfeit_turn()