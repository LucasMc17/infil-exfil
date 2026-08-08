@tool
class_name NavZoneExit
extends Resource

@export_group("Configs")
@export var local_position : Vector2i
@export var to_zone_name : String

@export_group("READ ONLY")
@export var board_position : Vector2i
@export var to_zone_uid : String

