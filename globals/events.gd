extends Node

# Turn events

signal player_turn_ended()

signal enemy_turn_ended()

# signal enemy_action_finished(enemy : EnemyUnit)

# Alarms

# TODO: alarm will be its own custom type.
signal alarm_raised(alarm, raiser : EnemyUnit)

signal alarm_ended()