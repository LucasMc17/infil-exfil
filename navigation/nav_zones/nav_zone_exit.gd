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
@export var to_zone_name : String
## Find the UUID of the zone identified in the to_zone field here.
@export_tool_button("Wire Up To-Zone") var wire_up_button = func(): _wire_up_to_zone()

@export_group("READ ONLY", "ro")
## READ ONLY version of the UID of the zone which this exit leads to.
@export var ro_to_zone_uid : String

## The UID of the zone which this exit leads to.
var to_zone_uid : String:
	get():
		return ro_to_zone_uid

func _validate_property(property : Dictionary) -> void:
	if property.name.begins_with("ro_"):
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _wire_up_to_zone() -> void:
	var level = EditorInterface.get_edited_scene_root()
	if level is not Level:
		printerr("Not currently editing a level.")
		return
	
	var to_zone = level.nav_system.find_nav_zone_by_name(to_zone_name)
	if !to_zone:
		printerr("No zone by that name found in level.")
		return
	
	ro_to_zone_uid = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(to_zone.resource_path))


func _highlight_exit() -> void:
	var plugin = Utilities.get_grid_map_plugin()

	plugin.set_selection(position, position)