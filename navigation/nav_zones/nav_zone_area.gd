@tool
class_name NavZoneArea
extends Resource

@export var position : Vector3i
@export var dimensions : Vector2i

func has_point(point : Vector3i) -> bool:
	if point.y != position.y:
		print("MISMATCH")
		return false
	print("STILL ALIVE")
	var true_rect = Rect2i(Vector2i(position.x, position.z), dimensions)
	return true_rect.has_point(Vector2i(point.x, point.z))