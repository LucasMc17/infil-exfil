class_name KillHostage
extends Skill

func get_visibility() -> bool:
	return !!user.captive


func use() -> void:
	user.release_captive(true, true)
	super()