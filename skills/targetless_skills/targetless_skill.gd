class_name TargetlessSkill
extends Skill

func use() -> void:
	super()
	Events.targetless_skill_used.emit(self, user)