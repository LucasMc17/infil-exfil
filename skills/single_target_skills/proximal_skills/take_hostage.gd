extends ProximalSkill

func get_visibility() -> bool:
	return !user.captive


func use() -> void:
	user.take_captive(target)
	super()