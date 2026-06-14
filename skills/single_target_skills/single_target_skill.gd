class_name SingleTargetSkill
extends Skill

@export_group("Targeting")
@export var effective_range := 5.0

@export_group("Cost")
@export var ammo_cost := 1

var skill_area : SkillTargetingArea
var potential_targets : Array[Unit] = []

func arm() -> void:
	super()
	DebugConsole.log(skill_area.get_all_targets(user))


func get_usability() -> bool:
	if !super():
		return false
	# TODO: Check area overlapping bodies here
	return !potential_targets.is_empty()


func refresh_targets() -> void:
	potential_targets = skill_area.get_all_targets(user)