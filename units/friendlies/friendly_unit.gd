@tool
class_name FriendlyUnit
extends Unit

@onready var _visible_zone := %VisibleZone


func check_for_detection():
	DebugConsole.log("Checking for detection", 2)
	_visible_zone.check_detection()

func _on_visible_zone_seen_by_enemies(enemies: Array[EnemyUnit]) -> void:
	DebugConsole.log("Friendly is Seen by Enemy/Enemies", 2)
	for enemy : EnemyUnit in enemies:
		enemy.awareness.alarm([self])
