extends ProximalSkill

func get_visibility() -> bool:
	return !user.captive


func begin_use() -> void:
	user.take_captive(target)
	super()