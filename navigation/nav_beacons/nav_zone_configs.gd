@tool
class_name NavZoneConfigFile
extends Resource

@export_group("Configs")
@export var areas : Array[Rect2i]
@export var points : Array[Vector2i]
@export var exits : Array[NavZoneExit]

@export_group("READ ONLY")
@export var base_position := Vector2i.ZERO
@export var board_points : Array[Vector2i]

func to_board_space(point : Vector2i) -> Vector2i:
	return point + base_position


func to_local_space(point : Vector2i) -> Vector2i:
	return point - base_position


func has_point(point : Vector2i) -> bool:
	var true_point = to_local_space(point)
	for rect : Rect2i in areas:
		if rect.has_point(true_point):
			return true
	return false


func get_nearest_exit(pos : Vector2i, banned_zones : Array[NavZoneConfigFile]) -> NavZoneExit:
	var result = null
	var distance_to_result = null
	for exit in exits:
		var zone = load(exit.to_zone_uid)
		var distance = exit.board_position.distance_to(pos)
		if !banned_zones.has(zone) and (!distance_to_result or distance < distance_to_result):
			distance_to_result = distance
			result = exit
	return result