class_name SkillTargetingArea
extends Area3D

var area_radius : float
var skill : Skill

@onready var _collision_shape : CollisionShape3D = %CollisionShape3D
@onready var _mesh_instance : MeshInstance3D = %MeshInstance3D
@onready var _skill_name : Label3D = %SkillName

func _ready() -> void:
	_mesh_instance.mesh = _mesh_instance.mesh.duplicate()
	_collision_shape.shape = SphereShape3D.new()
	_collision_shape.shape.radius = area_radius
	_skill_name.position.x = area_radius
	_skill_name.text = skill.name
	size_circle()


func get_all_targets(user : Unit) -> Array[Unit]:
	var is_friendly = user is FriendlyUnit
	var overlaps = get_overlapping_bodies()
	var result : Array[Unit] = []
	for overlapper in overlaps:
		if overlapper is Unit and overlapper != user and \
		(overlapper is EnemyUnit if is_friendly else overlapper is FriendlyUnit):
			if user.seen_zone.get_line_of_sight(overlapper.seen_zone.global_position, overlapper):
				result.append(overlapper)
	return result


func size_circle():
	_mesh_instance.mesh.bottom_radius = area_radius
	_mesh_instance.mesh.top_radius = area_radius - 0.05
