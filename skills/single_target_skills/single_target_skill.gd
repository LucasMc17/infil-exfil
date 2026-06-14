class_name SingleTargetSkill
extends Skill

@export_group("Targeting")
@export var effective_range := 5.0

@export_group("Cost")
@export var ammo_cost := 1

var skill_area : SkillTargetingArea

func arm(user) -> void:
	super(user)
	DebugConsole.log(skill_area.get_all_targets())


func get_usability(user : Unit) -> bool:
	if !super(user):
		return false
	# TODO: Check area overlapping bodies here
	return true