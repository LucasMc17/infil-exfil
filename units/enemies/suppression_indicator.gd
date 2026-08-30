@tool
class_name SuppressionIndicator
extends MeshInstance3D

@export_tool_button("Test line", "Callable") var test_button = generate_line

@export var end_point : Vector3

const THICKNESS := 0.02
var MATERIAL = load("uid://bc34jgntfn42b")

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		generate_line()


func generate_line() -> void:
	material_override = MATERIAL

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
	# mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(THICKNESS, 0, length))

	# mesh.surface_set_normal(Vector3(-1, 0, 0))

	# mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, 0, length))

	# mesh.surface_set_normal(Vector3(0, 1, 0))

	# mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(0, THICKNESS, length))

	
	# mesh.surface_set_normal(Vector3(0, -1, 0))

	# mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(0, -THICKNESS, length))




	# mesh.surface_set_normal(Vector3(0.5, 0.5, 0))

	# mesh.surface_add_vertex(Vector3(THICKNESS, 0, length))
	# mesh.surface_add_vertex(Vector3(0.0, THICKNESS, length))
	# mesh.surface_add_vertex(Vector3(THICKNESS, THICKNESS, 0.0))

	# mesh.surface_set_normal(Vector3(-0.5, 0.5, 0))

	# mesh.surface_add_vertex(Vector3(-THICKNESS, 0, length))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(0.0, THICKNESS, length))

	# mesh.surface_set_normal(Vector3(-0.5, -0.5, 0))

	# mesh.surface_add_vertex(Vector3(0.0, -THICKNESS, length))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, -THICKNESS, 0.0))
	# mesh.surface_add_vertex(Vector3(-THICKNESS, 0, length))

	# mesh.surface_set_normal(Vector3(0.5, -0.5, 0))

	# mesh.surface_add_vertex(Vector3(0.0, -THICKNESS, length))
	# mesh.surface_add_vertex(Vector3(THICKNESS, 0, length))
	# mesh.surface_add_vertex(Vector3(THICKNESS, -THICKNESS, 0.0))

	mesh.surface_end()

	look_at(end_point)
