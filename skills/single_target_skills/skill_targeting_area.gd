## An Area3D designed to gather valid targets for a [SingleTargetSkill].
class_name SkillTargetingArea
extends Area3D

## The radius of the targeting area.
var area_radius : float
## The skill which this area corresponds to.
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


## Takes in a user for this skill and returns an array of valid targets for this skill, based on team, line of sight, and distance.
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


## Initializes the circle which indicates the skill radius to the player.
func size_circle():
	_mesh_instance.mesh.bottom_radius = area_radius
	_mesh_instance.mesh.top_radius = area_radius - 0.05
