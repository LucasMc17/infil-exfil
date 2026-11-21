@tool
## An exit within a NavZone, linking it to another NavZone at a specific point.
class_name NavZoneExit
extends Resource

## Highlight the cell this exit occupies in the grid map.
@export_tool_button("Find Me") var find_button = func(): _highlight_exit()

@export_group("Configs")
## The position of this exit, relative to the root position of the nav_zone it is inside.
@export var position : Vector3i
## The name of the zone which this exit connects to, used by the wire up process to fetch its UID.
@export var to_zone_index : int = -1

var to_zone : NavZone

func _validate_property(property : Dictionary) -> void:
	if property.name.begins_with("ro_"):
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _highlight_exit() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	plugin.set_selection(position, position)