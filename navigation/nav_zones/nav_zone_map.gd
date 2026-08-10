@tool
## The holder for the entire system of [NavZone]s throughout a level. Organizes children into [NavZoneFloor]s.
class_name NavZoneMap
extends Node3D

## The floors within this NavZoneMap, in ascending order from the first and lowest floor to the highest.
var floors : Array[NavZoneFloor] = []

func _ready() -> void:
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is NavZoneFloor:
			child.floor_number = i
			floors.append(child)