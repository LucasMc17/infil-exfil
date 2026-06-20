@tool
class_name FriendlyUnit
extends Unit


func check_for_detection():
	DebugConsole.log("Checking for detection", 2)
	seen_zone.check_detection()


func _on_seen_zone_seen_by_enemies(enemies: Array[EnemyUnit]) -> void:
	DebugConsole.log("Friendly is Seen by Enemy/Enemies", 2)
	for enemy : EnemyUnit in enemies:
		enemy.awareness.alarm([self])
