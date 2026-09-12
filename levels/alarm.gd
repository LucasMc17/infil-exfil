class_name Alarm
extends Object

## Whether this alarm is acively raised.
var active := false
## The number of turns until this alarm shuts off.
var countdown := 6

func _init() -> void:
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.update_alarm_monitor.emit()


func raise(raiser : Unit) -> void:
	active = true
	countdown = 6
	Events.alarm_raised.emit(raiser)
	Events.update_alarm_monitor.emit()


func call_off() -> void:
	active = false
	countdown = 6
	Events.alarm_ended.emit()
	Events.update_alarm_monitor.emit()


func _on_enemy_turn_ended() -> void:
	if active:
		countdown -= 1
	if countdown < 1:
		call_off()
	Events.update_alarm_monitor.emit()