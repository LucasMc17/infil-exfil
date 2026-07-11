## Logic Module responsible for handling the execution of skills within a level.
class_name SkillHandlerModule
extends Object

func _init() -> void:
	Events.targetless_skill_used.connect(_on_targetless_skill_used)
	Events.aimed_skill_used.connect(_on_aimed_skill_used)


func _on_targetless_skill_used(skill : TargetlessSkill) -> void:
	DebugConsole.log("Targetless skill used: " + skill.name, 2)
	Events.skill_used.emit(skill)
	match skill.id:
		"reload":
			skill.user.primary_weapon.reload(false)
		"tactical_reload":
			skill.user.primary_weapon.reload(true)
		_:
			DebugConsole.warn("Unkown targetless skill used: " + skill.name)


func _on_aimed_skill_used(skill : AimedSkill, _target : Unit) -> void:
	DebugConsole.log("Aimed skill used: " + skill.name, 2)
	Events.skill_used.emit(skill)
	match skill.id:
		"headshot":
			pass
		"mozambique_drill":
			pass
		_:
			DebugConsole.warn("Unknown single target skill used: " + skill.name)