@tool
## An exit within a NavZone, linking it to another NavZone at a specific point.
class_name NavZoneExit
extends Resource

@export_group("Configs")
## The position of this exit, relative to the root position of the nav_zone it is inside.
@export var position : Vector3i
## The name of the zone which this exit connects to, used by the wire up process to fetch its UID.
@export var to_zone_name : String

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