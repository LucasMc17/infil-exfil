@tool
## A floor of [NavZone]s. Affixes all children to a consistent y-level in 3D space, based on the floor's index within the [NavZoneMap].
class_name NavZoneFloor
extends Node3D

var floor_number := 0:
	set(val):
		floor_number = val
		position.y = floor_number * 4