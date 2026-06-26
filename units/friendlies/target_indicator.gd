class_name TargetIndicator
extends Node

const MATERIAL := preload('res://assets/materials/immediate_mesh_material.tres')

@export var unit : FriendlyUnit

@onready var _line : MeshInstance3D = %Line

func draw_line(target_position : Vector3, color := Color.RED) -> void:
	if _line.mesh is not ImmediateMesh:
		_line.mesh = ImmediateMesh.new()
		_line.material_override = MATERIAL
	
	var mesh = _line.mesh
	
	mesh.clear_surfaces()

	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)

	mesh.surface_set_color(color)
	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(0, 0))
	mesh.surface_add_vertex(unit.global_position + Vector3(0, 1, 0))

	mesh.surface_set_color(color)
	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(target_position)

	mesh.surface_end()


# func _physics_process(_delta: float) -> void:
# 	draw_line(Vector3(0, 1, 1))
