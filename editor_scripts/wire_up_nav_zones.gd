@tool
class_name WireUpNavZones
extends EditorScript

func _run() -> void:
	var encountered := 0
	var errors := 0
	print("ATTEMPTING TO WIRE UP NAV ZONES")

	var level = EditorInterface.get_edited_scene_root()
	if level is not Level:
		printerr("CURRENT SCENE IS NOT A LEVEL. EXITING SCRIPT")
		return

	var level_dir_path = level.scene_file_path.get_base_dir()
	
	var nav_zone_path = level_dir_path + "/nav_zones/"

	var dir = DirAccess.open(level_dir_path)
	dir.make_dir("nav_zones")

	print(nav_zone_path)

	for zone : NavZoneHolder in level.get_tree().get_nodes_in_group("nav_zones"):
		var res = zone.configs
		if !res:
			printerr("NAV ZONE HOLDER WITH NO NAV ZONE CONFIG FILE FOUND")
			break
		var path = res.resource_path
		if !path.begins_with("res://") or "::" in path:
			var full_path = nav_zone_path + zone.name.to_snake_case() + ".tres"
			ResourceSaver.save(res, full_path)
			zone.configs = load(full_path)
	
	var nav_zone_system = level.nav_zone_map
	for node : Node3D in nav_zone_system.get_children():
		for zone_holder : NavZoneHolder in node.get_children():
			encountered += 1
			var configs : NavZone = zone_holder.configs
			
			# Setting base position
			if !configs:
				printerr("NAV ZONE " + zone_holder.name + "HAS NO CONFIGURED CONFIG FILE")
				errors += 1
			else:
				configs.ro_floor_number = zone_holder.floor_number
				configs.ro_base_position = zone_holder.position
				
				var board_points : Array[Vector3i] = []
				for point : Vector2i in configs.points:
					board_points.append(configs.to_board_space(point))
				configs.ro_board_points = board_points
			
				for exit : NavZoneExit in configs.exits:
					exit.ro_board_position = configs.to_board_space(exit.local_position)
					var to_zone = find_nav_zone_by_name(exit.to_zone_name, nav_zone_system)
					if !to_zone:
						printerr("FOR EXIT OF ZONE " + zone_holder.name + ", NO CONNECTING ZONE WITH NAME " + exit.to_zone_name + 'FOUND')
						errors += 1
					else:
						exit.ro_to_zone_uid = get_uid_from_resource(to_zone)
	
	print("ATTEMPTED TO WIRE UP " + str(encountered) + " NAV ZONES, WITH " + str(errors) + " ERRORS. EXITING SCRIPT")
	


func find_nav_zone_by_name(name : String, nav_zone_system : Node3D) -> NavZone:
	for child in nav_zone_system.get_children():
		for zone_holder : NavZoneHolder in child.get_children():
			if zone_holder.name == name:
				return zone_holder.configs
	return null

func get_uid_from_resource(resource: Resource) -> String:
	var path = resource.resource_path
	var int_id = ResourceLoader.get_resource_uid(path)
	return ResourceUID.id_to_text(int_id)