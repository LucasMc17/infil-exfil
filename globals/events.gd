extends Node

# Player turn events

signal player_turn_ended()

# Enemy turn events


# signal enemy_turn_ended()

# signal enemy_action_finished(enemy : EnemyUnit)

# Alarms

# TODO: alarm will be its own custom type.
signal alarm_raised(alarm, raiser : EnemyUnit)

signal alarm_ended()