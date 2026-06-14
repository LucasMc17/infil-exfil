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

var user : Unit

func make_unique() -> Skill:
	return self.duplicate(true)


func get_affordability() -> bool:
	return user.action_points >= cost


func arm() -> void:
	Events.skill_armed.emit(self)


func use() -> void:
	user.action_points -= cost
	Events.skill_disarmed.emit()