## Class representing a particular instance of a skill, as belonging to a specific unit. This is done so that we may store a mutable instance of a skill and treat the original resource as a read only data source. It also allows us to host the skill in physical space, which is useful for finding potential targets and locating an AOE on the grid.
@abstract class_name Skill
extends Node3D

## The type of this skill, as defined as what states it can be used from.
enum SkillType {
	## Skill can be used from any state.
	GENERAL,
	## Skill can only be used from stealth.
	STEALTH,
	## Skill can only be used from combat.
	COMBAT
}

## The skill's user.
@export var user : Unit

@export_group("Skill Info")
## The name of this skill.
@export var skill_name := "Skill Name"
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




# USABILITY FUNNEL
# This is a funnel to determine whether the skill is able to be used. The steps in the funnel are:
	# 1. The skill is visible. Some skills are contextual and so won't be displayed if irrelevant.
	# 2. The skill is affordable. If the user can afford to use the skill in terms of AP, MP and ammo, then it's button will not be disabled and grayed out.
	# 3. The skill is usable. Finally, whether the skill can actually be used or not. For some skills this will be dependent on whether or not there are available targets, and if one is actually picked.
# Only once all three steps are passed, the skill can be used.

## Returns true if this skill is visible to the user, considering context.
func get_visibility() -> bool:
	return true


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


## Disarm this skill, reset appropriate variables.
func disarm() -> void:
	pass


## Use this skill, and send all relevant signals in the global context.
func use() -> void:
	user.action_points -= action_cost
	user.movement_points -= movement_cost
	if ammo_cost and user.primary_weapon is RangedWeapon:
		user.primary_weapon.current_ammunition -= ammo_cost
	Events.skill_used.emit(self)
