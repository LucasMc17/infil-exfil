@tool
extends StaticBody3D

const MATERIAL = preload("uid://b0rlusiqnnw7i")

@onready var pivot_point : Node3D = %PivotPoint
@onready var body : StaticBody3D = %StaticBody3D
@onready var collision : CollisionShape3D = %CollisionShape3D
@onready var mesh : MeshInstance3D = %MeshInstance3D

## The width of the wall instance in meters.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var width := 1.0:
	set(val):
		width = val
		_set_size()


func _ready() -> void:
	collision.shape = BoxShape3D.new()
	collision.shape.size.x = 0.15
	collision.shape.size.y = 4

	mesh.mesh = BoxMesh.new()
	mesh.mesh.material = MATERIAL
	mesh.mesh.size.x = 0.15
	mesh.mesh.size.y = 4
	
	_set_size()


## Resize the wall to match the passed width.
func _set_size():
	if collision:
		collision.shape.size.z = width
		collision.position.z = width / 2
	
	if mesh:
		mesh.mesh.size.z = width
		mesh.position.z = width / 2
