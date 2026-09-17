class_name Alarm
extends Object

const MAX_COOLDOWN := 3

## Whether this alarm is acively raised.
var active := false
## The number of turns until this alarm shuts off.
var countdown := MAX_COOLDOWN
## The position this unit cites as having been where they encountered enemies.
var alarm_point : EnemyUnitAwarenessModule.ContactPoint
## Whether an enemy unit has investigated the alarm point this alarm was raised with.
var point_investigated := false
## Whether the friendly force has been acquired during this alarm phase.
# var friendlies_acquired := false
# NOTE: There's a case to be made that this should require that the point has been investigated or there are no more investigators AND all the other coniditions.
## Virtual property reflecting whether this alarm has been "satisfied" and can be called off when the countdown hits zero.
var alarm_satisfied : bool:
	get():
		return !_enemies_in_active_pursuit() and (point_investigated or _no_more_investigators())

func _init() -> void:
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	# Events.friendly_spotted.connect(_on_friendly_spotted)
	Events.update_alarm_monitor.emit()


func reset() -> void:
	countdown = MAX_COOLDOWN
	point_investigated = false
	# friendlies_acquired = false


func _enemies_in_active_pursuit() -> bool:
	for enemy in Level.current_level.live_enemies:
		if enemy.awareness.friendlies_in_sight.size() > 0 or enemy.decision_director.current_directive is Pursue:
			return true
	return false

## A failsafe, reflecting whether there are no more enemy units investigating the alarm point.
func _no_more_investigators() -> bool:
	for enemy in Level.current_level.live_enemies:
		if enemy.decision_director.current_directive is InvestigateAlarmPoint:
			return false
	return true


func raise(raiser : Unit) -> void:
	active = true
	reset()
	if raiser is EnemyUnit:
		alarm_point = raiser.awareness.last_poc
	else:
		alarm_point = EnemyUnitAwarenessModule.ContactPoint.new(raiser.board_position)
	# friendlies_acquired = Level.current_level.enemy_awareness.friendlies_in_sight()
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
	else:
		countdown = MAX_COOLDOWN
	if countdown < 1:
		call_off()
	Events.update_alarm_monitor.emit()


# func _on_friendly_spotted() -> void:
# 	if active:
# 		friendlies_acquired = true