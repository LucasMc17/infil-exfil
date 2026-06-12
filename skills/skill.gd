@abstract class_name Skill
extends Resource

enum SkillType {
	GENERAL,
	STEALTH,
	COMBAT
}

@export_group("Skill Info")
@export var name := "Skill Name"
@export_multiline var description := "Skill description"
@export var skill_type := SkillType.GENERAL
@export var cost := 1

func use(user : Unit, target : Unit, target_position : Vector3) -> void:
	pass