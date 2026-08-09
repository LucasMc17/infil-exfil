@tool
class_name WireUpNavZones
extends EditorScript

func _run() -> void:
	var encountered := 0
	var errors := 0
	print("ATTEMPTING TO WIRE UP NAV ZONES")

	var level = EditorInterface.get_edited_scene_root()
	if level is not BaseLevel:
		print("ERROR: CURRENT SCENE IS NOT A LEVEL. EXITING SCRIPT")
		return
	
	var nav_zone_system = level._beacon_holder
	for node : Node3D in nav_zone_system.get_children():
		for zone_holder : NavZoneHolder in node.get_children():
			encountered += 1
			var configs : NavZoneConfigFile = zone_holder.configs
			
			# Setting base position
			if !configs:
				print("NAV ZONE " + zone_holder.name + "HAS NO CONFIGURED CONFIG FILE")
				errors += 1
			else:
				configs.base_position = zone_holder.position
				
				var board_points : Array[Vector3i] = []
				for point : Vector2i in configs.points:
					board_points.append(configs.to_board_space(point))
				configs.board_points = board_points
			
				for exit : NavZoneExit in configs.exits:
					exit.board_position = configs.to_board_space(exit.local_position)
					var to_zone = find_nav_zone_by_name(exit.to_zone_name, nav_zone_system)
					if !to_zone:
						print("FOR EXIT OF ZONE " + zone_holder.name + ", NO CONNECTING ZONE WITH NAME " + exit.to_zone_name + 'FOUND')
						errors += 1
					else:
						exit.to_zone_uid = get_uid_from_resource(to_zone)
	
	print("ATTEMPTED TO WIRE UP " + str(encountered) + " NAV ZONES, WITH " + str(errors) + " ERRORS. EXITING SCRIPT")
	


func find_nav_zone_by_name(name : String, nav_zone_system : Node3D) -> NavZoneConfigFile:
	for child in nav_zone_system.get_children():
		for zone_holder : NavZoneHolder in child.get_children():
			if zone_holder.name == name:
				return zone_holder.configs
	return null

func get_uid_from_resource(resource: Resource) -> String:
	var path = resource.resource_path
	var int_id = ResourceLoader.get_resource_uid(path)
	return ResourceUID.id_to_text(int_id)