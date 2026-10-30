class_name PullAlarm
extends Skill

func get_visibility() -> bool:
	if !super():
		return false
	return Level.current.nav_map.alarms.has(user.board_position)


func get_affordability() -> bool:
	if !super():
		return false
	return Level.current.nav_map.alarms.has(user.board_position)


func begin_use() -> void:
	super()
	if user is EnemyUnit:
		user.speak("Alert! Intruders!")
	Level.current.alarm.raise(user)
	