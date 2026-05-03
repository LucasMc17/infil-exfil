class_name Tile
extends Resource

@export var name : String
@export var navigable := true

@export var should_respect_rotation := true

@export var viable_neighbors : Array[TileConnection] = []

func get_viable_connections(position : Vector3i, basis : Basis) -> Dictionary[Vector3i, bool]:
	var result : Dictionary[Vector3i, bool] = {}
	if navigable:
		for neighbor : TileConnection in viable_neighbors:
			var to_add = neighbor.relative_position
			if should_respect_rotation:
				to_add = Vector3i(Vector3(to_add) * basis)
			result[position + to_add] = neighbor.must_be_two_way
	
	return result