@tool
class_name Sniper
extends FriendlyUnit


var queued_target : EnemyUnit
var scoped_target : EnemyUnit

func lose_target() -> void:
	if scoped_target:
		scoped_target = null
	if queued_target:
		queued_target = null

func _on_player_turn_ended() -> void:
	if scoped_target:
		scoped_target = null
	if queued_target:
		scoped_target = queued_target
		queued_target = null


func _on_move() -> void:
	lose_target()


func _on_damage() -> void:
	lose_target()


func _on_die() -> void:
	lose_target()