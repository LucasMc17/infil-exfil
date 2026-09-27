@tool
class_name Chunk
## Custom resource representing a reusable chunk of cells for a GridMap.
extends Resource

## The name of the unique chunk.
@export var name : String
## The dimensions of the chunk, on the x, y and z axis, for visualizing before loading.
@export var dimensions : Vector3i
## The stringified data of this chunk. The schema of the JSON is as follows:[br]
## Each key in the object is a string of three integers separated by slashes, like so: "0/0/0". This is a stringified [Vector3i] representing the position of the tile this key value pair describes within the map chunk.[br]
## Each value in the object is a string of two integers separated by a dash, like so: "1-0". the first integer represents the cell index, and the second is the rotational index.[br]
## Together, these three points describe the position, cell type and rotation of a given point in the grid map, and can be used to reconstruct the chunk anywhere.
@export var content : String

## Return a stringified vector to a full vector format ("0/1/2" -> Vector3(0.0, 1.0, 1.0)).
static func unstringify_vector3(string : String) -> Vector3:
	var axes = Array(string.split('/')).map(func (i): return int(i))
	return Vector3(axes[0], axes[1], axes[2])


func to_dict() -> Dictionary[Vector3i, Vector2i]:
	var result : Dictionary[Vector3i, Vector2i] = {}
	var data = JSON.parse_string(content)
	for key in data.keys():
		var position = Vector3i(unstringify_vector3(key))
		var value = data[key].split('-')
		var cell_item = int(value[0])
		var cell_rotation = int(value[1])

		result[Vector3i(ChunkOperator.grid_map_plugin.get_selection().position) + position] = Vector2i(cell_item, cell_rotation)
	return result
