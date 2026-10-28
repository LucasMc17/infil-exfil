@tool
class_name Sniper
extends FriendlyUnit


var queued_target : EnemyUnit
var scoped_target : EnemyUnit

func _on_player_turn_ended() -> void:
	if scoped_target:
		scoped_target = null
	if queued_target:
		scoped_target = queued_target
		queued_target = null