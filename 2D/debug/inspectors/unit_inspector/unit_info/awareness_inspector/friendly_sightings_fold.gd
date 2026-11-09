@tool
extends FoldingInspector

@onready var _friendlies_in_sight : DebugKVPair = %FriendliesInSight
@onready var _friendlies_out_of_sight : DebugKVPair = %FriendliesOutOfSight
@onready var _all_friendlies : VBoxContainer = %AllFriendlies

func refresh(friendly_knowledge : FriendlyKnowledgeModule) -> void:
	_friendlies_in_sight.value = str(friendly_knowledge.all_in_sight.size())
	_friendlies_out_of_sight.value = str(friendly_knowledge.all_out_of_sight.size())

	Utilities.clear_children(_all_friendlies)
	for sighting in friendly_knowledge.sightings.values():
		_all_friendlies.add_child(UnitSightingInspector.new_inspector(sighting))