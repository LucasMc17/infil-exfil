class_name PullAlarm
extends Skill

func get_visibility() -> bool:
	if !super():
		return false
	return Level.current_level.nav_map.alarms.has(user.board_position)


func get_affordability() -> bool:
	if !super():
		return false
	return Level.current_level.nav_map.alarms.has(user.board_position)


func begin_use() -> void:
	super()
	Level.current_level.alarm.raise(user)
	