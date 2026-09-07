@tool
## The holder for the entire system of [NavZone]s throughout a level. Organizes children into [NavZoneFloor]s.
class_name NavZoneMap
extends Node3D

@export_tool_button("Wire Up Zones", "Callable") var wire_up_button = func() -> void:
	var instance = WireUpNavZones.new()
	instance._run()

## The floors within this NavZoneMap, in ascending order from the first and lowest floor to the highest.
var floors : Array[NavZoneFloor] = []

func _ready() -> void:
	child_order_changed.connect(_assign_floor_heights)
	_assign_floor_heights()


## Utility function for assigning each child's floor index within the map.
func _assign_floor_heights() -> void:
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is NavZoneFloor:
			child.floor_number = i
			floors.append(child)