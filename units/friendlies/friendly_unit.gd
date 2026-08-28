@tool
## A unit under direct control by the player.
class_name FriendlyUnit 
extends Unit

func check_for_detection() -> void:
	DebugConsole.log("Checking for detection", 2)
	var unit_id = get_instance_id()
	for enemy : EnemyUnit in Level.current_level.all_enemies:
		enemy.awareness.confirm_specific_sighting(unit_id)
	seen_zone.check_detection()
	get_instance_id()


func _on_seen_zone_seen_by_enemies(enemies: Array[EnemyUnit]) -> void:
	DebugConsole.log("Friendly is Seen by Enemy/Enemies", 2)
	for enemy : EnemyUnit in enemies:
		enemy.awareness.alarm(self, false)
