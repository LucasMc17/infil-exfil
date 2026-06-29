## A [Skill] designed for aiming at and using on one particular unit, who is in range and in sight.
class_name SingleTargetSkill
extends Skill

@export_group("Targeting")
## The range which the target must be within to be targetable for the skill.
@export var effective_range := 5.0

## [SkillTargetingArea] for isolating targets for this skill.
var skill_area : SkillTargetingArea
## An array of potential targets which are currently valid for this skill.
var potential_targets : Array[Unit] = []

func arm() -> void:
	super()
	get_usability()


func get_usability() -> bool:
	refresh_targets()
	return !potential_targets.is_empty()


## Refresh the list of valid targets.
func refresh_targets() -> void:
	potential_targets = skill_area.get_all_targets(user)


func use() -> void:
	super()
	# TODO: To update once targeting system is finished.
	Events.single_target_skill_used.emit(self, user, user)