@tool
class_name NavZoneArea
extends Resource

## Highlight the cells this area occupies in the grid map.
@export_tool_button("Find Me") var find_button = func(): _highlight_area()

@export var position : Vector3i
@export var dimensions : Vector2i

func has_point(point : Vector3i) -> bool:
	if point.y != position.y:
		return false
	var true_rect = Rect2i(Vector2i(position.x, position.z), dimensions)
	return true_rect.has_point(Vector2i(point.x, point.z))


func _highlight_area() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	plugin.set_selection(position, position + Vector3i(dimensions.x - 1, 0, dimensions.y - 1))