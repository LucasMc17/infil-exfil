@tool
## Holds all of the [NavZones] for a level and provides debug visuals for the [NavZones] within it. Also contains useful functions related to nav zones within a specific level.
@icon("uid://bhw5hse8etfk0")
class_name NavSystem
extends Node3D

## The material to apply to meshes representing navigation points within this NavZoneHolder.
static var POINT_MATERIAL = FileReference.new("uid://cvcg462nivceg")

## The full list of [NavZones] utilized within this level.
@export var nav_zones : Array[NavZone] = []

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and is_visible_in_tree():
		_redraw_meshes()


## The function which continually redraws the mesh in editor to visualize this NavZoneHolder.
func _redraw_meshes() -> void:
	Utilities.clear_children(self)

	for nav_zone : NavZone in nav_zones:
		for area : NavZoneArea in nav_zone.areas:
			if area != null:
				var plane_material = StandardMaterial3D.new()
				plane_material.albedo_color = nav_zone.debug_color
				var mesh_instance = MeshInstance3D.new()
				var plane_mesh = PlaneMesh.new()
				plane_mesh.material = plane_material
				mesh_instance.mesh = plane_mesh

				mesh_instance.mesh.size.x = abs(area.dimensions.x)
				mesh_instance.mesh.size.y = abs(area.dimensions.y)
				mesh_instance.position.y = area.position.y * 4 + 0.1
				mesh_instance.position.x = (float(area.dimensions.x) / 2) + area.position.x
				mesh_instance.position.z = (float(area.dimensions.y) / 2) + area.position.z

				add_child(mesh_instance)
		
		for point : Vector3i in nav_zone.points:
			if point != null:
				var mesh_instance = MeshInstance3D.new()
				var box_mesh = BoxMesh.new()
				box_mesh.material = POINT_MATERIAL.value
				mesh_instance.position = Vector3(point) + Vector3(0.5, 0.0, 0.5)

				mesh_instance.mesh = box_mesh

				add_child(mesh_instance)
		
		for exit in nav_zone.exits:
			if exit:
				var mesh_instance = MeshInstance3D.new()
				var cylinder_mesh = CylinderMesh.new()
				mesh_instance.position = Vector3(exit.position) + Vector3(0.5, 0.0, 0.5)

				mesh_instance.mesh = cylinder_mesh

				add_child(mesh_instance)


func find_nav_zone_by_name(name : String) -> NavZone:
	for nav_zone : NavZone in nav_zones:
		if nav_zone.name == name:
			return nav_zone
	return null


## Returns the [NavZone] a given position is in.
func get_zone_from_position(pos : Vector3i) -> NavZone:
	for nav_zone : NavZone in nav_zones:
		if nav_zone.has_point(pos):
			return nav_zone
	return null