@tool
extends StaticBody3D

const MATERIAL = preload("uid://b0rlusiqnnw7i")

@onready var collision : CollisionShape3D = %CollisionShape3D
@onready var mesh : MeshInstance3D = %MeshInstance3D

## The width of the floor instance in meters.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var width := 1.0:
	set(val):
		width = val
		_set_size()
## The depth of the floor instance in meters.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var depth := 1.0:
	set(val):
		depth = val
		_set_size()

func _ready() -> void:
	collision.shape = BoxShape3D.new()
	collision.shape.size.y = 0.1

	mesh.mesh = BoxMesh.new()
	mesh.mesh.material = MATERIAL
	mesh.mesh.size.y = 0.1
	
	_set_size()


## Dynamically resize the floor instance based on the supplied width and depth.
func _set_size():
	if collision:
		collision.shape.size.z = depth
		collision.position.z = depth / 2
		collision.shape.size.x = width
		collision.position.x = width / 2
	
	if mesh:
		mesh.mesh.size.z = depth
		mesh.position.z = depth / 2
		mesh.mesh.size.x = width
		mesh.position.x = width / 2