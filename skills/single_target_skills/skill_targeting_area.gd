@tool
class_name SkillTargetingArea
extends Area3D

var area_radius : float

@onready var _collision_shape : CollisionShape3D = %CollisionShape3D
@onready var _mesh_instance : MeshInstance3D = %MeshInstance3D

func _ready() -> void:
	_mesh_instance.mesh = _mesh_instance.mesh.duplicate()
	_collision_shape.shape = SphereShape3D.new()
	_collision_shape.shape.radius = area_radius
	size_circle()


func get_all_targets(user : Unit) -> Array[Unit]:
	var is_friendly = user is FriendlyUnit
	var overlaps = get_overlapping_bodies()
	var result : Array[Unit] = []
	for overlapper in overlaps:
		if overlapper is Unit and overlapper != user and \
		(overlapper is EnemyUnit if is_friendly else overlapper is FriendlyUnit):
			if user.seen_zone.get_line_of_sight(overlapper.seen_zone.global_position, overlapper):
				result.append(overlapper)
	return result


func size_circle():
	_mesh_instance.mesh.bottom_radius = area_radius
	_mesh_instance.mesh.top_radius = area_radius - 0.05


# func draw_empty_circle():
# 	var UP = Vector3(0,1,0)

# 	var array_mesh = ImmediateMesh.new()
	
# 	var st = SurfaceTool.new()
# 	st.begin(Mesh.PRIMITIVE_LINE_STRIP)
# 	st.set_color(Color(1, 0, 0))
# 	st.set_uv(Vector2(0, 0))
# 	st.add_vertex(Vector3(0, 0, 0))
# 	st.add_vertex(Vector3(-1, -1, 0))
# 	st.add_vertex(Vector3(-3, -2, 0))
# 	st.add_vertex(Vector3(0, 0, 0))
# 	var mesh = st.commit()
# 	_mesh_instance.mesh = mesh


	# _mesh.clear()
	# _mesh.begin(Mesh.PRIMITIVE_LINE_LOOP)
	# for i in range(int(resolution)):
	# 	var rotation = float(i) / resolution * TAU
	# 	add_vertex(rotated(UP, circle_radius-circle_center) + circle_center)
	# end()
