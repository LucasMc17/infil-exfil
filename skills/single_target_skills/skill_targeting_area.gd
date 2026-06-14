class_name SkillTargetingArea
extends Area3D

var area_radius : float

@onready var _collision_shape : CollisionShape3D = %CollisionShape3D

func _ready() -> void:
	_collision_shape.shape = SphereShape3D.new()
	_collision_shape.shape.radius = area_radius


func get_all_targets(user : Unit) -> Array[Unit]:
	var is_friendly = user is FriendlyUnit
	var overlaps = get_overlapping_bodies()
	var result : Array[Unit] = []
	for overlapper in overlaps:
		if overlapper is Unit and overlapper != user and \
		(overlapper is EnemyUnit if is_friendly else overlapper is FriendlyUnit):
			result.append(overlapper)
	return result
