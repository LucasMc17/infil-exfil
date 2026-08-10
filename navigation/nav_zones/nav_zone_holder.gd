@tool
## The holder for a [NavZoneHolder] resource in 3D game space. This class has two main purposes: [br]
## 1. To provide a spot in the scene tree for holding the NavZoneHolder resources which make up the Ai-enabled navigation layer of a level.
## 2. To draw debug visuals representing the NavZones in 3D space for ease of editing in the editor. In the compiled game, these scenes should have no visual component at all.
class_name NavZoneHolder
extends Node3D

## The material to apply to meshes representing navigation points within this NavZoneHolder.
const POINT_MATERIAL = preload("uid://cvcg462nivceg")

@export_tool_button("Start/Stop Debug Visuals") var start_stop_button = func():
	show_visuals = !show_visuals
@export_tool_button("Assign Random Color") var random_color_button = func():
	debug_color = Utilities.random_color()

## The NavZoneHolder resource file which populates this holder.
@export var configs : NavZone 
## The color to assign to the debug meshes for this NavZoneHolder in editor
@export var debug_color : Color:
	set(val):
		debug_color = val
		if Engine.is_editor_hint() and plane_material:
			plane_material.albedo_color = debug_color

## Whether or not to create and update debug meshes in the editor for this NavZoneHolder. Can be turned off in order to declutter the editor space.
var show_visuals := true
## The material to apply to the debug mesh of this NavZoneHolder (when drawn).
var plane_material : StandardMaterial3D
## The floor number of this zone.
var floor_number := 0

func _ready() -> void:
	if Engine.is_editor_hint():
		plane_material = StandardMaterial3D.new()
		plane_material.albedo_color = debug_color


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and show_visuals:
		_redraw_meshes()


## The function which continually redraws the mesh in editor to visualize this NavZoneHolder.
func _redraw_meshes() -> void:
	for child in get_children():
		child.queue_free()

	if configs:
		for rect : Rect2i in configs.areas:
			if rect != null:
				var mesh_instance = MeshInstance3D.new()
				var plane_mesh = PlaneMesh.new()
				plane_mesh.material = plane_material
				mesh_instance.mesh = plane_mesh

				mesh_instance.mesh.size.x = abs(rect.size.x)
				mesh_instance.mesh.size.y = abs(rect.size.y)
				mesh_instance.position.y = 0.1
				mesh_instance.position.x = (float(rect.size.x) / 2) + rect.position.x
				mesh_instance.position.z = (float(rect.size.y) / 2) + rect.position.y

				add_child(mesh_instance)
		
		for point : Vector2i in configs.points:
			if point != null:
				var mesh_instance = MeshInstance3D.new()
				var box_mesh = BoxMesh.new()
				box_mesh.material = POINT_MATERIAL
				mesh_instance.position.x = point.x + 0.5
				mesh_instance.position.z = point.y + 0.5

				mesh_instance.mesh = box_mesh

				add_child(mesh_instance)
		
		for exit in configs.exits:
			if exit:
				var mesh_instance = MeshInstance3D.new()
				var cylinder_mesh = CylinderMesh.new()
				mesh_instance.position.x = exit.local_position.x + 0.5
				mesh_instance.position.z = exit.local_position.y + 0.5

				mesh_instance.mesh = cylinder_mesh

				add_child(mesh_instance)

			
