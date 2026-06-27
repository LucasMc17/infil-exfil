class_name SkillHandler
extends Object

func _init() -> void:
	Events.targetless_skill_used.connect(_on_targetless_skill_used)
	Events.single_target_skill_used.connect(_on_single_target_skill_used)


func _on_targetless_skill_used(skill : TargetlessSkill, user : Unit) -> void:
	DebugConsole.log("Targetless skill used: " + skill.name, 2)
	Events.skill_used.emit(skill, user)
	match skill.id:
		"reload":
			user.primary_weapon.reload(false)
		"tactical_reload":
			user.primary_weapon.reload(true)
		_:
			DebugConsole.warn("Unkown targetless skill used: " + skill.name)


func _on_single_target_skill_used(skill : SingleTargetSkill, user : Unit, target : Unit) -> void:
	DebugConsole.log("Single target skill used: " + skill.name, 2)
	Events.skill_used.emit(skill, user)
	match skill.id:
		"headshot":
			pass
		"mozambique_drill":
			pass
		_:
			DebugConsole.warn("Unknown single target skill used: " + skill.name)