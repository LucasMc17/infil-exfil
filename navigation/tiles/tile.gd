@tool
## Resource representing a specific type of tile in the [NavigableGridMap], and specifically listing its potential connections to neighboring tiles as [TileConnection] resources.
class_name Tile
extends Resource 

## The name of the tile type.
@export var name : String
## Boolean representing whether or not the tile is navigable.
@export var navigable := true
## Whether or not the relative positions of possible connections should account for the rotation of the specific tile instance.
@export var should_respect_rotation := true
## Array of potential connections for this tile.
@export var viable_neighbors : Array[TileConnection] = []

## Returns a dictionary of relative positions to which this tile should connect.
func get_viable_connections(position : Vector3i, basis : Basis) -> Dictionary[Vector3i, bool]:
	var result : Dictionary[Vector3i, bool] = {}
	if navigable:
		for neighbor : TileConnection in viable_neighbors:
			var to_add = neighbor.relative_position
			if should_respect_rotation:
				to_add = Vector3i(Vector3(to_add) * basis)
			result[position + to_add] = neighbor.must_be_two_way
	
	return result