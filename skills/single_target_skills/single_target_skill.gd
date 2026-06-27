class_name SingleTargetSkill
extends Skill

@export_group("Targeting")
@export var effective_range := 5.0

var skill_area : SkillTargetingArea
var potential_targets : Array[Unit] = []

func arm() -> void:
	super()
	get_usability()


func get_usability() -> bool:
	refresh_targets()
	return !potential_targets.is_empty()


func refresh_targets() -> void:
	potential_targets = skill_area.get_all_targets(user)


func use() -> void:
	super()
	# TODO: To update once targeting system is finished.
	Events.single_target_skill_used.emit(self, user, user)