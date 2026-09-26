@tool
class_name ChunkPreviewer
extends Object

var preview_layer : GridMap
var grid_map : GridMap
var grid_map_plugin : GridMapEditorPlugin
var chunk_loader : ChunkLoader
var preview_mesh_lib : MeshLibrary

func _init(gm : GridMap, gmp : GridMapEditorPlugin, l : ChunkLoader) -> void:
	grid_map = gm
	grid_map_plugin = gmp
	chunk_loader = l


## Set the selection of the current GridMap to the dimensions of the chunk, showing exactly how large it will be, and how many tiles it may potentially replace.
func preview(chunk : Chunk) -> void:

	_create_preview_layer()

	chunk_loader.load(preview_layer, chunk)

	# grid_map_plugin.set_selection(position, Vector3i(position) + chunk.dimensions)


# TODO: Find a way to do this efficiently
func _create_preview_mesh_lib() -> void:
	preview_mesh_lib = grid_map.mesh_library.duplicate(true)
	for mesh_id in preview_mesh_lib.get_item_list():
		var mesh = preview_mesh_lib.get_item_mesh(mesh_id)
		var mat = mesh.surface_get_material(0).duplicate(true)
		
		if mat and mat is StandardMaterial3D:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.5
		
		mesh.surface_set_material(0, mat)
	
	if preview_layer:
		preview_layer.mesh_library = preview_mesh_lib

func _create_preview_layer() -> void:
	_clear_preview_layer()
	preview_layer = grid_map.duplicate()
	preview_layer.position = Vector3.ZERO
	preview_layer.clear()
	grid_map.add_child(preview_layer)
	print("preview layer created")
	print(grid_map.get_child_count())
	_create_preview_mesh_lib()


func _clear_preview_layer() -> void:
	if preview_layer:
		preview_layer.free()