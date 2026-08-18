class_name KillHostage
extends Skill

func get_visibility() -> bool:
	return !!user.captive


func begin_use() -> void:
	user.audio_machine.play_audio('gunshot')
	user.release_captive(true, true)
	super()