## A skill which requires no specific target and can be performed without one.
class_name TargetlessSkill
extends Skill

func use() -> void:
	super()
	Events.targetless_skill_used.emit(self, user)