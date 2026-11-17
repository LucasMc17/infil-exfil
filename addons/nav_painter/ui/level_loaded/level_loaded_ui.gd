## The UI to display in the dock when a level has succesfully loaded, with or without NavZones already saved.
class_name LevelLoadedUI
extends VBoxContainer

@onready var _nav_zone_previews : VBoxContainer = %NavZonePreviews

## The level that was loaded.
var level : Level

## Runs when the UI is loaded after detecting a level.
func activate(loaded : Level) -> void:
	visible = true
	level = loaded
	var level_dir_path = level.scene_file_path.get_base_dir()
	var nav_zone_path = level_dir_path + '/nav_zones/'
	var level_dir = DirAccess.open(level_dir_path)
	level_dir.make_dir("nav_zones")
	var nav_zone_dir = DirAccess.open(nav_zone_path)
	if nav_zone_dir:
		nav_zone_dir.list_dir_begin()
		var file_name = nav_zone_dir.get_next()
		while file_name != "":
			if !nav_zone_dir.current_is_dir():
				var nav_zone : NavZone = load(nav_zone_path + file_name) as NavZone
	


## Runs when the UI is unloaded for any reason.
func deactivate() -> void:
	visible = false
	level = null
	Utilities.clear_children(_nav_zone_previews)
