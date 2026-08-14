@tool
## A floor of [NavZone]s. Affixes all children to a consistent y-level in 3D space, based on the floor's index within the [NavZoneMap].
class_name NavZoneFloor
extends Node3D

## Virtual property of all the zone holders directly held by this floor of the nav zone map.
var zone_holders : Array[NavZoneHolder]:
	get():
		var result : Array[NavZoneHolder]
		for child in get_children():
			if child is NavZoneHolder:
				result.append(child)
		return result

## The index of the floor which this scene represents in the nav zone map.
var floor_number := 0:
	set(val):
		floor_number = val
		position.y = floor_number * 4
		for child in get_children():
			if child is NavZoneHolder:
				child.floor_number = floor_number