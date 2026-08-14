class_name PullAlarm
extends Skill

func get_visibility() -> bool:
	if !super():
		return false
	return World.level.nav_map.alarms.has(user.board_position)


func get_affordability() -> bool:
	if !super():
		return false
	return World.level.nav_map.alarms.has(user.board_position)


func begin_use() -> void:
	super()
	Events.alarm_raised.emit(null, user)