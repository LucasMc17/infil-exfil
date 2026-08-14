@tool
class_name BuildDebugWalls
extends EditorScript

const DEBUG_FLOOR := preload("uid://d1i1gcecs1k5t")
const DEBUG_WALL := preload("uid://dygqxfucs53hc")

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var encountered := 0
	print("ATTEMPTING TO BUILD DEBUG WALLS")

	var level = EditorInterface.get_edited_scene_root()
	if level is not BaseLevel:
		print("ERROR: CURRENT SCENE IS NOT A LEVEL. EXITING SCRIPT")
		return

	var geometry = level.geometry
	var nav_map : NavigableGridMap = level.nav_map

	for child in geometry.get_children():
		child.queue_free()

	for coord : Vector3i in nav_map.point_map_by_grid_coords.keys():
		encountered += 1
		var point : NavigableGridMap.GridPoint = nav_map.point_map_by_grid_coords[coord]
		var global_coord = NavigableGridMap.convert_grid_to_global_position(coord)
		if point.tile.wall_floor:
			var floor_scene = DEBUG_FLOOR.instantiate()
			floor_scene.position = global_coord
			geometry.add_child(floor_scene)
			floor_scene.owner = level
		
		if point.tile.wall_front:
			var wall_scene = DEBUG_WALL.instantiate()
			wall_scene.position = global_coord + Vector3(0.5, 0, 0.5)
			wall_scene.rotation.y = -point.basis.get_euler().y
			geometry.add_child(wall_scene)
			wall_scene.owner = level
		
		if point.tile.wall_right:
			var wall_scene = DEBUG_WALL.instantiate()
			wall_scene.position = global_coord + Vector3(0.5, 0, 0.5)
			wall_scene.rotation.y = -point.basis.get_euler().y - 1.5708
			geometry.add_child(wall_scene)
			wall_scene.owner = level
		
		if point.tile.wall_left:
			var wall_scene = DEBUG_WALL.instantiate()
			wall_scene.position = global_coord + Vector3(0.5, 0, 0.5)
			wall_scene.rotation.y = -point.basis.get_euler().y + 1.5708
			geometry.add_child(wall_scene)
			wall_scene.owner = level
		
		if point.tile.wall_right:
			var wall_scene = DEBUG_WALL.instantiate()
			wall_scene.position = global_coord + Vector3(0.5, 0, 0.5)
			wall_scene.rotation.y = -point.basis.get_euler().y - 1.5708
			geometry.add_child(wall_scene)
			wall_scene.owner = level
		
		if point.tile.wall_back:
			var wall_scene = DEBUG_WALL.instantiate()
			wall_scene.position = global_coord + Vector3(0.5, 0, 0.5)
			wall_scene.rotation.y = -point.basis.get_euler().y + PI
			geometry.add_child(wall_scene)
			wall_scene.owner = level
	
	print("CREATED DEBUG WALLS FOR " + str(encountered) + " TILES.")


