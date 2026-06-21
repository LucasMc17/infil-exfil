@abstract class_name Skill
extends Resource

enum SkillType {
	GENERAL,
	STEALTH,
	COMBAT
}

@export_group("Skill Info")
@export var name := "Skill Name"
@export var id := "skill_name"
@export_multiline var description := "Skill description"
@export var skill_type := SkillType.GENERAL

@export_group("Cost")
@export var action_cost := 1
@export var movement_cost := 0
@export var ammo_cost := 0

var user : Unit

func make_unique() -> Skill:
	return self.duplicate(true)


func get_affordability() -> bool:
	if user.action_points >= action_cost && user.movement_points >= movement_cost:
		if ammo_cost:
			return user.primary_weapon is RangedWeapon && user.primary_weapon.current_ammunition >= ammo_cost
		return true
	return false


func get_usability() -> bool:
	return true

func arm() -> void:
	Events.skill_armed.emit(self)


func use() -> void:
	user.action_points -= action_cost
	user.movement_points -= movement_cost
	if ammo_cost and user.primary_weapon is RangedWeapon:
		user.primary_weapon.current_ammunition -= ammo_cost