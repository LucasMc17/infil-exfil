@tool
class_name NavZone
extends Node3D

const MATERIAL = preload("uid://btwnpllh8x3b4")

@export var width := 1.0:
	set(val):
		width = val
		_resize()
@export var depth := 1.0:
	set(val):
		depth = val
		_resize()

var _editor_mesh : MeshInstance3D
var rect : Rect2

func _ready() -> void:
	rect = Rect2(Vector2(position.x - 0.1, position.z - 0.1), Vector2(width + 0.2, depth + 0.2))
	if Engine.is_editor_hint():
		_editor_mesh = MeshInstance3D.new()
		var plane_mesh = PlaneMesh.new()
		plane_mesh.material = MATERIAL
		_editor_mesh.mesh = plane_mesh
		_resize()
		add_child(_editor_mesh)


func has_point(point : Vector2i) -> bool:
	return rect.has_point(point)


func _resize() -> void:
	rect = Rect2(Vector2(position.x - 0.1, position.z - 0.1), Vector2(width + 0.2, depth + 0.2))
	if _editor_mesh:
		_editor_mesh.mesh.size.x = width
		_editor_mesh.mesh.size.y = depth
		_editor_mesh.position.y = 0.1
		_editor_mesh.position.x = width / 2
		_editor_mesh.position.z = depth / 2