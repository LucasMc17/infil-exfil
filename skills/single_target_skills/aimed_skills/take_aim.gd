class_name TakeAim
extends AimedSkill

func begin_use() -> void:
	if user is Sniper:
		user.queued_target = target
	super()