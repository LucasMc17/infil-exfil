@tool
extends FoldingInspector

@onready var _enemies_in_sight : DebugKVPair = %EnemiesInSight
@onready var _enemies_out_of_sight : DebugKVPair = %EnemiesOutOfSight
@onready var _all_enemies : VBoxContainer = %AllEnemies

func refresh(enemy_knowledge : EnemyKnowledgeModule) -> void:
	_enemies_in_sight.value = str(enemy_knowledge.all_in_sight.size())
	_enemies_out_of_sight.value = str(enemy_knowledge.all_out_of_sight.size())

	Utilities.clear_children(_all_enemies)
	for sighting in enemy_knowledge.sightings.values():
		_all_enemies.add_child(EnemySightingInspector.new_inspector(sighting))