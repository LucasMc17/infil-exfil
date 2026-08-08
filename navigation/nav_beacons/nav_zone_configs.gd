@tool
class_name NavZoneConfigFile
extends Resource

@export var base_position := Vector2i.ZERO


@export var areas : Array[Rect2i]

@export var points : Array[Vector2i]

@export var exits : Array[NavZoneExit]


func _to_board_space(point : Vector2i) -> Vector2i:
	return point - base_position


func has_point(point : Vector2i) -> bool:
	var true_point = _to_board_space(point)
	for rect : Rect2i in areas:
		if rect.has_point(true_point):
			return true
	return false


func get_nearest_exit(pos : Vector2i, banned_zones : Array[NavZoneConfigFile]) -> NavZoneConfigFile:
	var result = null
	var nearest = null
	for exit in exits:
		var zone = load(exit.to_zone)
		var distance = exit.local_position.distance_to(_to_board_space(pos))
		if !banned_zones.has(zone) and (!nearest or distance < nearest):
			nearest = distance
			result = zone
	return result