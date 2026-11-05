## Custom class representing a single point, both in the grid map and the A* grid. Contains information about that point's position, tile type, connections, mesh ID, rotation and A* ID. Designed to allow for easy referencing of specific spoints in the context of either the GridMap or the A* grid.
class_name GridPoint
extends Object

## The ID of the mesh occupying this point in the GridMap.
var mesh_id : int
## The ID of this point in the A* nav grid.
var a_star_point : int
## The rotational basis of the point.
var basis : Basis
## The position of this point in the NavGrid.
var position : Vector3i
## The [Tile] type of this point.
var tile : Tile
## A dictionary representing the absolute positions of possible connections to this tile based on its type, without consideration of whether they are actually able to connect.
var potential_connections : Dictionary[Vector3i, bool]
## A dictionary of astar points which this tile has an unstable connection to, capable of being severed under certain circumstances.
var unstable_connected_points : Array[int]
## A dictionary representing the absolute positions of real connections for this point in the A* grid.
var connections : Dictionary[Vector3i, bool]:
	get():
		var result : Dictionary[Vector3i, bool]
		for id in NavigableGridMap.current.astar.get_point_connections(a_star_point):
			result[NavigableGridMap.current.point_map_by_astar_ids[id].position] = true
		return result
## The name of the mesh shown at this position in the GridMap.
var mesh_name : String:
	get():
		return NavigableGridMap.current.TILE_PALETTE[mesh_id].name
## The movable object occupying this point (and blocking it for use in pathing).
var occupier : Node3D = null

func _init(p_position: Vector3i, p_mesh_id : int, p_a_star_point : int, p_basis : Basis, p_tile : Tile):
	mesh_id = p_mesh_id
	a_star_point = p_a_star_point
	basis = p_basis
	position = p_position
	tile = p_tile
	potential_connections = tile.get_viable_connections(position, basis)
	var unstable_neighbors = tile.get_unstable_connections(position, basis)
	for neighbor in unstable_neighbors:
		if NavigableGridMap.current.point_map_by_grid_coords.has(neighbor):
			unstable_connected_points.append(NavigableGridMap.current.point_map_by_grid_coords[neighbor].a_star_point)