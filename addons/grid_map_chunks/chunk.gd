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