@tool
class_name FriendlyUnit
extends Unit

@onready var _target_indicator : TargetIndicator = %TargetIndicator


func check_for_detection():
	DebugConsole.log("Checking for detection", 2)
	seen_zone.check_detection()


func _on_seen_zone_seen_by_enemies(enemies: Array[EnemyUnit]) -> void:
	DebugConsole.log("Friendly is Seen by Enemy/Enemies", 2)
	for enemy : EnemyUnit in enemies:
		enemy.awareness.alarm([self])


func draw_target(target : EnemyUnit) -> void:
	_target_indicator.draw_line(target.global_position)
	_target_indicator.visible = true


func clear_target() -> void:
	_target_indicator.visible = false