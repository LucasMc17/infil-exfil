extends AimedSkill

func begin_use() -> void:
	user.audio_machine.play_audio('gunshot')
	target.damage(1)
	super()