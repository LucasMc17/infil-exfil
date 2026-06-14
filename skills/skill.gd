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

func make_unique() -> Skill:
	return self.duplicate(true)


func get_usability(user : Unit) -> bool:
	return user.action_points >= cost


func arm(_user) -> void:
	Events.skill_armed.emit(self)


func use(user : Unit, target : Unit, target_position : Vector3) -> void:
	pass