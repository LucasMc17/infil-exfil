class_name PullAlarm
extends Skill

func get_visibility() -> bool:
	return World.level.nav_map.alarms.has(user.actual_position)


func get_affordability() -> bool:
	if !super():
		return false
	return World.level.nav_map.alarms.has(user.actual_position)


func use() -> void:
	Events.alarm_raised.emit(null, user)