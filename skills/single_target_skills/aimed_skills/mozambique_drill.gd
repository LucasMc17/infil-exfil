class_name MozambiqueDrill
extends AimedSkill


func begin_use() -> void:
	user.audio_machine.play_audio('gunshot')
	target.die()
	super()