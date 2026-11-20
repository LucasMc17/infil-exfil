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
	
	for child in level.nav_zone_map.get_children():
		for zone_holder : NavZoneHolder in child.get_children():
			if zone_holder.name == to_zone_name:
				ro_to_zone_uid = _get_uid_from_resource(_find_nav_zone_by_name(to_zone_name, level.nav_zone_map))
				return
	
	printerr("No zone by that name found in level.")


func _get_uid_from_resource(resource: Resource) -> String:
	var path = resource.resource_path
	var int_id = ResourceLoader.get_resource_uid(path)
	return ResourceUID.id_to_text(int_id)


func _find_nav_zone_by_name(name : String, nav_zone_system : Node3D) -> NavZone:
	for child in nav_zone_system.get_children():
		for zone_holder : NavZoneHolder in child.get_children():
			if zone_holder.name == name:
				return zone_holder.configs
	return null


func _highlight_exit() -> void:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var plugins = editor_root.find_children("",  "GridMapEditorPlugin", true, false)

	if plugins.is_empty():
			printerr("No active grid map plugin")
			return

	var plugin = plugins[0]

	plugin.set_selection(position, position)