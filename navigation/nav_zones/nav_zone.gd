@tool
## A "zone" within the navigable map, used to demarcate the map into distinct areas or rooms which the AI can use to estimate the likely path another unit took when in pursuit.
class_name NavZone
extends Resource

@export_group("Configs")
## A series of rectangles defining the borders of the zone, relative to the zone's base position.
@export var areas : Array[Rect2i]
## A series of points within the zone which can be used for precise pathing inside of it.
@export var points : Array[Vector2i]
## A series of exits which this NavZone uses to connect to other NavZones, and mark the point at which the connection applies.
@export var exits : Array[NavZoneExit]

@export_group("READ ONLY", "ro_")
## READ ONLY version of the base position of the zone in 3d space.
@export var ro_base_position := Vector3i.ZERO
## READ ONLY version of the points within this zone, adjusted to 3d space based on the base position.
@export var ro_board_points : Array[Vector3i]
## READ ONLY version of the index of the Y-level this NavZone is located on.
@export var ro_floor_number := 0

func _validate_property(property : Dictionary) -> void:
	if property.name.begins_with("ro_"):
		property.usage |= PROPERTY_USAGE_READ_ONLY

## The base position of the zone in 3d space.
var base_position : Vector3i:
	get():
		return ro_base_position
## The points within this zone, adjusted to 3d space based on the base position.
var board_points : Array[Vector3i]:
	get():
		return ro_board_points
## The index of the Y-level this NavZone is located on.
var floor_number : int:
	get():
		return ro_floor_number

## Translates a 2D point within this NavZone to real, 3D space in terms of the navigable grid map.
func to_board_space(point : Vector2i) -> Vector3i:
	return Vector3i(point.x, floor_number, point.y) + base_position


## Translates 3D nav grid coordinates into local, 2d coordinates.
func to_local_space(point : Vector3i) -> Vector2i:
	var temp = point - base_position
	return Vector2i(temp.x, temp.z)


## Takes in a point in 3D space and returns true if that space, once translated to local 2D coordinates, is within the NavZone.
func has_point(point : Vector3i) -> bool:
	var true_point = to_local_space(point)
	for rect : Rect2i in areas:
		if rect.has_point(true_point):
			return true
	return false


## Takes in a 3D point and returns the 3D position of the nearest point within this NavZone to that point.
func get_nearest_point(pos : Vector3i) -> Vector3i:
	var result = null
	var distance_to_result = null
	for point : Vector3i in board_points:
		var distance = pos.distance_to(point)
		if !distance_to_result or distance < distance_to_result:
			distance_to_result = distance
			result = point
	return result


## Takes in a 3D point and returns the nearest exit within this NavZone. If banned zones are provided, exits leading to them will be excluded from consideration.
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


## Takes in a 3D point and returns a random exit from this NavZone, with closer exits weighted more heavily. If banned zones are provided, exits leading to them will be excluded from consideration.
func get_semirandom_exit(pos : Vector3i, banned_zones : Array[NavZone]) -> NavZoneExit:
	var potential_exits : Array[NavZoneExit] = []
	var weights : Array[float] = []
	for exit in exits:
		var zone = load(exit.to_zone_uid)
		if !banned_zones.has(zone):
			potential_exits.append(exit)
			weights.append(exit.board_position.distance_to(pos))
	return Utilities.weighted_pick_random(potential_exits, weights, true)
