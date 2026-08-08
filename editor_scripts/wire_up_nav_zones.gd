@tool
class_name WireUpNavZones
extends EditorScript

func _run() -> void:
	var encountered := 0
	var success := 0
	print("ATTEMPTING TO WIRE UP NAV ZONES")

	var level = EditorInterface.get_edited_scene_root()
	if level is not BaseLevel:
		print("ERROR: CURRENT SCENE IS NOT A LEVEL. EXITING SCRIPT")
		return
	
	var nav_zone_system = level._beacon_holder
	for node : Node3D in nav_zone_system.get_children():
		for zone_holder : NavZone in node.get_children():
			encountered += 1
			var configs : NavZoneConfigFile = zone_holder.configs
			if !configs:
				print("NAV ZONE " + zone_holder.name + "HAS NO CONFIGURED CONFIG FILE")
			else:
				configs.base_position = Vector2i(zone_holder.position.x, zone_holder.position.z)
				success += 1
	
	print("WIRED UP " + str(success) + "/" + str(encountered) + " NAV ZONES. EXITING SCRIPT")
	