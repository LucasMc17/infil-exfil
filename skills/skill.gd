## Abstract class representing an action that a Unit can take, and spend action points on during their turn.
@abstract class_name Skill
extends Resource

## The type of this skill, as defined as what states it can be used from.
enum SkillType {
	## Skill can be used from any state.
	GENERAL,
	## Skill can only be used from stealth.
	STEALTH,
	## Skill can only be used from combat.
	COMBAT
}

@export_group("Skill Info")
## The name of this skill.
@export var name := "Skill Name"
## The unique ID of this skill, especially for use in the [SkillHandler] logic module.
@export var id := "skill_name"
## A description of this skill for the player's benefit.
@export_multiline var description := "Skill description"
## The type of this skill.
@export var skill_type := SkillType.GENERAL

@export_group("Cost")
## The cost of performing this skill, in terms of action points.
@export var action_cost := 1
## The cost of performing this skill, in terms of movement points.
@export var movement_cost := 0
## The cost of performing this skill, in terms of ammunition for the primary weapon.
@export var ammo_cost := 0

## The skill's user.
var user : Unit

## Return a unique instance of this resource.
func make_unique() -> Skill:
	return self.duplicate(true)


## Return true if this skill is affordable to the user, in terms of action points, movement points, and ammunition.
func get_affordability() -> bool:
	if user.action_points >= action_cost && user.movement_points >= movement_cost:
		if ammo_cost:
			if DebugOptions.ammo_mode as int == 2:
				return true
			else:
				return user.primary_weapon is RangedWeapon && user.primary_weapon.current_ammunition >= ammo_cost
		return true
	return false


## Return true if this skill is not only affordable, but usable by other, usually custom metrics.
func get_usability() -> bool:
	return true


## Arm this skill in the UI, and perform relevant checks to gather usability.
func arm() -> void:
	pass


## Use this skill, and send all relevant signals in the global context.
func use() -> void:
	user.action_points -= action_cost
	user.movement_points -= movement_cost
	if ammo_cost and user.primary_weapon is RangedWeapon:
		user.primary_weapon.current_ammunition -= ammo_cost