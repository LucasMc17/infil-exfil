## An Area3D designed to gather valid targets for an [AimedSkill].
class_name AimedSkill
extends Skill

@export_group("Targeting")
## The range which the target must be within to be targetable for the skill.
@export var effective_range := 5.0

## An array of potential targets which are currently valid for this skill.
var potential_targets : Array[Unit] = []
## The currently selected target.
var target : Unit

@onready var _collision_shape : CollisionShape3D = %CollisionShape3D
@onready var _mesh_instance : MeshInstance3D = %MeshInstance3D
@onready var _skill_name : Label3D = %SkillName
@onready var _area : Area3D = %Area3D

func _ready() -> void:
	_collision_shape.shape.radius = effective_range
	_skill_name.position.x = effective_range
	_skill_name.text = skill_name
	size_circle()


func get_usability() -> bool:
	get_all_targets()
	return !potential_targets.is_empty()


func arm() -> void:
	super()
	get_usability()


## Takes in a user for this skill and returns an array of valid targets for this skill, based on team, line of sight, and distance.
func get_all_targets() -> void:
	var is_friendly = user is FriendlyUnit
	var overlaps = _area.get_overlapping_bodies()
	var result : Array[Unit] = []
	for overlapper in overlaps:
		if overlapper is Unit and overlapper != user and \
		(overlapper is EnemyUnit if is_friendly else overlapper is FriendlyUnit):
			if user.seen_zone.get_line_of_sight(overlapper.seen_zone.global_position, overlapper):
				result.append(overlapper)
	potential_targets = result


## Target the skill to a particular unit, change all necessary variables.
func retarget(new_target : Unit) -> void:
	target = new_target


## Initializes the circle which indicates the skill radius to the player.
func size_circle():
	_mesh_instance.mesh.bottom_radius = effective_range
	_mesh_instance.mesh.top_radius = effective_range - 0.05
