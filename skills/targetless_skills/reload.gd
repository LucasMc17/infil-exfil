class_name Reload
extends Skill

@export var is_tactical := false

func get_affordability() -> bool:
	if !super():
		return false
	return user.primary_weapon.current_ammunition < user.primary_weapon.capacity && \
	user.primary_weapon.current_reserve_ammo > 0


func begin_use() -> void:
	user.audio_machine.play_audio('reload')
	user.primary_weapon.reload(is_tactical)
	super()