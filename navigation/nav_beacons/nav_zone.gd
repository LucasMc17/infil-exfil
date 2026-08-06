@tool
class_name NavZone
extends Node3D

const POINT_MATERIAL = preload("uid://cvcg462nivceg")

@export var configs : NavZoneConfigFile:
	set(val):
		configs = val
		_redraw_meshes()

@export var debug_color : Color:
	set(val):
		debug_color = val
		if Engine.is_editor_hint() and plane_material:
			plane_material.albedo_color = debug_color
				

var _debug_meshes : Array[MeshInstance3D]

var _nav_meshes : Array[MeshInstance3D]

var _exit_meshes : Array[MeshInstance3D]

var plane_material : StandardMaterial3D

@export var test_point := Vector2i(0,0):
	set(val):
		test_point = val
		print(has_point(test_point))

func _ready() -> void:
	print("ENTERING")
	if Engine.is_editor_hint():
		if configs:
			configs.changed.connect(_redraw_meshes)
		plane_material = StandardMaterial3D.new()
		plane_material.albedo_color = debug_color
		_redraw_meshes()


func has_point(point : Vector2i) -> bool:
	# Translate to local space
	var local_point = point - Vector2i(position.x, position.z)
	for rect : Rect2i in configs.areas:
		if rect.has_point(local_point):
			return true
	return false


func _redraw_meshes() -> void:
	_debug_meshes.clear()
	_nav_meshes.clear()
	_exit_meshes.clear()

	for child in get_children():
		child.queue_free()

	if configs:
		for rect : Rect2i in configs.areas:
			var mesh_instance = MeshInstance3D.new()
			var plane_mesh = PlaneMesh.new()
			plane_mesh.material = plane_material
			mesh_instance.mesh = plane_mesh
			_debug_meshes.append(mesh_instance)

			mesh_instance.mesh.size.x = abs(rect.size.x)
			mesh_instance.mesh.size.y = abs(rect.size.y)
			mesh_instance.position.y = 0.1
			mesh_instance.position.x = (float(rect.size.x) / 2) + rect.position.x
			mesh_instance.position.z = (float(rect.size.y) / 2) + rect.position.y

			add_child(mesh_instance)
		
		for point : Vector2i in configs.points:
			var mesh_instance = MeshInstance3D.new()
			var box_mesh = BoxMesh.new()
			box_mesh.material = POINT_MATERIAL
			mesh_instance.position.x = point.x + 0.5
			mesh_instance.position.z = point.y + 0.5
			_nav_meshes.append(mesh_instance)

			mesh_instance.mesh = box_mesh

			add_child(mesh_instance)
		
		for exit : Vector2i in configs.exits:
			var mesh_instance = MeshInstance3D.new()
			var cylinder_mesh = CylinderMesh.new()
			mesh_instance.position.x = exit.x + 0.5
			mesh_instance.position.z = exit.y + 0.5
			_exit_meshes.append(mesh_instance)

			mesh_instance.mesh = cylinder_mesh

			add_child(mesh_instance)

			
# func _resize() -> void:
# 	rect = Rect2(Vector2(global_position.x, global_position.z), Vector2(width, depth))
# 	if _editor_mesh:
# 		_editor_mesh.mesh.size.x = width - 0.2
# 		_editor_mesh.mesh.size.y = depth - 0.2
# 		_editor_mesh.position.y = 0.1
# 		_editor_mesh.position.x = (width) / 2
# 		_editor_mesh.position.z = (depth) / 2
