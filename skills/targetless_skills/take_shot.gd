class_name TakeShot
extends Skill

func get_affordability() -> bool:
	if !super():
		return false
	return user is Sniper and user.scoped_target


func begin_use() -> void:
	if user is Sniper and user.scoped_target:
		user.audio_machine.play_audio('gunshot')
		user.scoped_target.die()
		user.scoped_target = null
		user.queued_target = null
	super()


func end_use() -> void:
	Level.current_level.level_camera.fix_to_actor(Unit.active_unit)
	super()


func arm() -> void:
	super()
	if user is Sniper and user.scoped_target:
		Level.current_level.level_camera.jump_to_point(user.scoped_target.global_position)
