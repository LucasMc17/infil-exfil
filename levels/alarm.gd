class_name Alarm
extends Object

const MAX_COOLDOWN := 3

## Whether this alarm is acively raised.
var active := false
## The number of turns until this alarm shuts off.
var countdown := MAX_COOLDOWN
## The position this unit cites as having been where they encountered enemies.
var alarm_point : Vector3i
## Whether an enemy unit has investigated the alarm point this alarm was raised with.
var point_investigated := false
## Whether the friendly force has been acquired during this alarm phase.
var friendlies_acquired := false
## A failsafe, reflecting whether there are no more enemy units investigating the alarm point.
var no_more_investigators := false
## Virtual property reflecting whether this alarm has been "satisfied" and can be called off when the countdown hits zero.
var alarm_satisfied : bool:
	get():
		return !_enemies_in_active_pursuit() and (point_investigated or friendlies_acquired or no_more_investigators)

func _init() -> void:
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.update_alarm_monitor.emit()


func reset() -> void:
	countdown = MAX_COOLDOWN
	point_investigated = false
	no_more_investigators = false
	friendlies_acquired = false


func _enemies_in_active_pursuit() -> bool:
	for enemy in Level.current_level.live_enemies:
		if enemy.awareness.friendlies_in_sight.size() > 0 or enemy.decision_director.current_directive is Pursue:
			return true
	print('No enemies in pursuit')
	return false


func raise(raiser : Unit) -> void:
	active = true
	reset()
	if raiser is EnemyUnit:
		alarm_point = raiser.awareness.last_poc.position
	else:
		alarm_point = raiser.board_position
	Events.alarm_raised.emit(raiser)
	Events.update_alarm_monitor.emit()


func call_off() -> void:
	active = false
	reset()
	Events.alarm_ended.emit()
	Events.update_alarm_monitor.emit()


func _on_enemy_turn_ended() -> void:
	if active and alarm_satisfied:
		countdown -= 1
	if countdown < 1:
		call_off()
	Events.update_alarm_monitor.emit()