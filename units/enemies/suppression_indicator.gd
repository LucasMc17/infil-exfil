@tool
class_name SuppressionIndicator
extends MeshInstance3D

const THICKNESS := 0.02

var _active_target : Unit
var MATERIAL = load("uid://bc34jgntfn42b")

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint() and !!_active_target:
		generate_line()


func activate(target : Unit):
	_active_target = target
	visible = true


func deactivate():
	_active_target = null
	visible = false


func generate_line() -> void:
	material_override = MATERIAL

	var end_point = _active_target.position
	end_point.y += 1.0

	var length = -global_position.distance_to(end_point)

	mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)


	mesh.surface_set_normal(Vector3(1, 0, 0))

	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0))

	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, length))
	
	mesh.surface_set_normal(Vector3(-1, 0, 0))

	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0))

	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, length))
	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0))

	mesh.surface_set_normal(Vector3(0, 1, 0))
	
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, length))

	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, length))
	mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, length))

	mesh.surface_set_normal(Vector3(0, -1, 0))
	
	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0))

	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0))
	mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, length))
	mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, length))

	mesh.surface_end()

	look_at(end_point)
