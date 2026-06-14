class_name SkillTargetingArea
extends Area3D

var area_radius : float

@onready var _collision_shape : CollisionShape3D = %CollisionShape3D

func _ready() -> void:
	_collision_shape.shape = SphereShape3D.new()
	_collision_shape.shape.radius = area_radius


func get_all_targets() -> Array[Unit]:
	var overlaps = get_overlapping_bodies()
	var result : Array[Unit] = []
	for overlapper in overlaps:
		if overlapper is Unit:
			result.append(overlapper)
	return result
