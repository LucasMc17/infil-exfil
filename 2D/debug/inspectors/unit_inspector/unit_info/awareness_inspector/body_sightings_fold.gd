@tool
extends FoldingInspector

@onready var _bodies_seen : DebugKVPair = %BodiesSeen
@onready var _all_bodies : VBoxContainer = %AllBodies

func refresh(friendly_knowledge : FriendlyKnowledgeModule, enemy_knowledge : EnemyKnowledgeModule) -> void:
	_bodies_seen.value = str(friendly_knowledge.bodies.size() + enemy_knowledge.bodies.size())

	Utilities.clear_children(_all_bodies)
	for sighting in friendly_knowledge.bodies.values():
		_all_bodies.add_child(BodySightingInspector.new_inspector(sighting))
	for sighting in enemy_knowledge.bodies.values():
		_all_bodies.add_child(BodySightingInspector.new_inspector(sighting))