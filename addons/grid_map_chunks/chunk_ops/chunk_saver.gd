@tool
class_name ChunkSaver
extends Object

var saved_chunks_path : String

func _init(path : String) -> void:
	saved_chunks_path = path

## Stringifies the selected GridMap data into a JSON object with it's own schema (see [Chunk.content] for more details).
func _serialize_points(points : Array, local_root : Vector3i, grid_map : GridMap) -> String:
	var result = {}
	for point : Vector3i in points:
		var local_point = point - local_root
		var key = _stringify_vector3(local_point)
		var cell = grid_map.get_cell_item(point)
		var cell_rotation = grid_map.get_cell_item_orientation(point)
		var value = str(cell) + "-" + str(cell_rotation)
		result[key] = value
	
	return JSON.stringify(result)


## Utility function for reducing a Vector3/Vector3i to a string (Vector3i(0, 1, 2) -> "0/1/2").
func _stringify_vector3(vector : Variant) -> String:
	if vector is Vector3 or vector is Vector3i:
		return str(vector.x) + "/" + str(vector.y) + "/" + str(vector.z)
	else:
		return ""


## Serialize a chunk of map data as a reusable Chunk, and save that chunk to a tres in the file system.
func save(name : String, points : Array, selection : AABB, grid_map : GridMap) -> bool:
	var chunk = Chunk.new()

	chunk.dimensions = selection.size
	chunk.name = name
	chunk.content = _serialize_points(points, Vector3i(selection.position), grid_map)

	var error := ResourceSaver.save(chunk, saved_chunks_path + name + '.tres')

	return error == OK