## Class representing a particular instance of a skill, as belonging to a specific unit. This is done so that we may store a mutable instance of a skill and treat the original resource as a read only data source. It also allows us to host the skill in physical space, which is useful for finding potential targets and locating an AOE on the grid.
@abstract class_name Skill
extends Node

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
# NOTE: Long term, the below variable will be replaced with the length of the animation associated with this particular skill. This is strictly for the time being.
## The time in seconds it takes to perform the skill.
@export var time_to_perform := 1.0


@export_group("Conditions")
## Whether or not this skill will be shown to the player while holding a hostage.
@export var visible_with_hostage := false
## The cost of performing this skill, in terms of action points.
@export var action_cost := 1
## The cost of performing this skill, in terms of movement points.
@export var movement_cost := 0
## The cost of performing this skill, in terms of ammunition for the primary weapon.
@export var ammo_cost := 0

var is_armed : bool:
	get():
		if World.level:
			return World.level.armed_skill == self
		else:
			return false


# USABILITY FUNNEL
# This is a funnel to determine whether the skill is able to be used. The steps in the funnel are:
	# 1. The skill is visible. Some skills are contextual and so won't be displayed if irrelevant.
	# 2. The skill is affordable. If the user can afford to use the skill in terms of AP, MP and ammo, then it's button will not be disabled and grayed out.
	# 3. The skill is usable. Finally, whether the skill can actually be used or not. For some skills this will be dependent on whether or not there are available targets, and if one is actually picked.
# Only once all three steps are passed, the skill can be used.

## Returns true if this skill is visible to the user, considering context.
func get_visibility() -> bool:
	if !visible_with_hostage and user.captive:
		return false
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


## Set up the skill with overrides, used only when the skill is being used by an enemy unit.
func setup_overrides(_overrides : Dictionary) -> void:
	pass
	

## Arm this skill in the UI, and perform relevant checks to gather usability.
func arm() -> void:
	pass


## Disarm this skill, reset appropriate variables.
func disarm() -> void:
	pass


## Use this skill, and send all relevant signals in the global context.
func begin_use() -> void:
	# user.action_machine.current_state.transition("Action", {"skill": self})
	user.action_points -= action_cost
	user.movement_points -= movement_cost
	if ammo_cost and user.primary_weapon is RangedWeapon:
		user.primary_weapon.current_ammunition -= ammo_cost
	Events.skill_used.emit(self)
	Events.refresh_unit_skills.emit()


func end_use() -> void:
	pass