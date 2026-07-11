class_name Reload
extends TargetlessSkill

@export var is_tactical := false

func get_affordability() -> bool:
	if !super():
		return false
	return user.primary_weapon.current_ammunition < user.primary_weapon.capacity && \
	user.primary_weapon.current_reserve_ammo > 0


func use() -> void:
	user.primary_weapon.reload(is_tactical)
	super()