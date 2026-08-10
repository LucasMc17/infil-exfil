@tool
class_name NavZone
extends Resource

@export_group("Configs")
@export var areas : Array[Rect2i]
@export var points : Array[Vector2i]
@export var exits : Array[NavZoneExit]

@export_group("READ ONLY")
@export var base_position := Vector3i.ZERO
@export var board_points : Array[Vector3i]
@export var floor_number := 0

func to_board_space(point : Vector2i) -> Vector3i:
	return Vector3i(point.x, 0, point.y) + base_position


func to_local_space(point : Vector3i) -> Vector2i:
	var temp = point - base_position
	return Vector2i(temp.x, temp.z)


func has_point(point : Vector3i) -> bool:
	var true_point = to_local_space(point)
	for rect : Rect2i in areas:
		if rect.has_point(true_point):
			return true
	return false


func get_nearest_point(pos : Vector3i) -> Vector3i:
	var result = null
	var distance_to_result = null
	for point : Vector3i in board_points:
		var distance = pos.distance_to(point)
		if !distance_to_result or distance < distance_to_result:
			distance_to_result = distance
			result = point
	return result


func get_nearest_exit(pos : Vector3i, banned_zones : Array[NavZone]) -> NavZoneExit:
	var result = null
	var distance_to_result = null
	for exit in exits:
		var zone = load(exit.to_zone_uid)
		var distance = exit.board_position.distance_to(pos)
		if !banned_zones.has(zone) and (!distance_to_result or distance < distance_to_result):
			distance_to_result = distance
			result = exit
	return result