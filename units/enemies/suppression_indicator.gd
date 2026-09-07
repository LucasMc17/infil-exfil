@tool
class_name SuppressionIndicator
extends MeshInstance3D

@export var owning_unit : EnemyUnit

const THICKNESS := 0.02
var CLEAR_LOS_MATERIAL = load("uid://bc34jgntfn42b")
var BLOCKED_LOS_MATERIAL = load("uid://cxisxshg58hjp")

var _active_target : Unit
var _los_clear := true

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint() and !!_active_target:
		generate_line()


func activate(target : Unit):
	_los_clear = true
	_active_target = target
	visible = true


func deactivate():
	_los_clear = true
	_active_target = null
	visible = false


func generate_line() -> void:
	material_override = CLEAR_LOS_MATERIAL if _los_clear else BLOCKED_LOS_MATERIAL

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


func check_los(can_see := true) -> void:
	if can_see:
		_los_clear = true
		material_override = CLEAR_LOS_MATERIAL
	else:
		_los_clear = false
		material_override = BLOCKED_LOS_MATERIAL
