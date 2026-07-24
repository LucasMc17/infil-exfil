@tool
extends MeshInstance3D

const MATERIAL = preload("res://assets/materials/nav_beacon_material.tres")

var start_point : Vector3
var end_point: Vector3

func _ready() -> void:
	var distance = Vector2(start_point.x, start_point.z).distance_to(Vector2(end_point.x, end_point.z))
	var direction = (end_point - start_point).normalized()
	var angle = atan2(-direction.x, -direction.z)
	rotation.y = angle

	mesh = ImmediateMesh.new()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(1, 1))

	mesh.surface_add_vertex(Vector3(0, 0.1, 0))
	mesh.surface_add_vertex(Vector3(0.1, 0.1, 0))
	mesh.surface_add_vertex(Vector3(0.05, end_point.y - start_point.y + 0.1, -distance))

	mesh.surface_end()
	mesh.surface_set_material(0, MATERIAL)