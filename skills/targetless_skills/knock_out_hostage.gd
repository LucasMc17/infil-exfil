class_name KnockOutHostage
extends Skill

func get_visibility() -> bool:
	return !!user.captive


func begin_use() -> void:
	user.release_captive(true, false)
	super()