@tool
## The UI to display in the dock when a level has succesfully loaded, with or without NavZones already saved.
class_name LevelLoadedUI
extends VBoxContainer

@onready var _nav_zone_previews : VBoxContainer = %NavZonePreviews

## The level that was loaded.
var level : Level
## An array of Nav Zone files found in the above level's directory.
var nav_zones : Array[NavZone] = []

## Runs when the UI is loaded after detecting a level.
func activate(loaded : Level) -> void:
	visible = true
	level = loaded
	_find_level_nav_zones()
	_populate_previews()


## Runs when the UI is unloaded for any reason.
func deactivate() -> void:
	visible = false
	level = null
	nav_zones = []
	Utilities.clear_children(_nav_zone_previews)


func _find_level_nav_zones() -> void:
	if !level:
		return
	nav_zones = []
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
				nav_zones.append(nav_zone)
			file_name = nav_zone_dir.get_next()


func _populate_previews() -> void:
	Utilities.clear_children(_nav_zone_previews)
	for zone in nav_zones:
		var preview : NavZonePreview = NavZonePreview.new_preview(zone)
		preview.find_requested.connect(_find_nav_zone_in_level)
		_nav_zone_previews.add_child(preview)


func _find_nav_zone_in_level(zone : NavZone) -> void:
	if !level or EditorInterface.get_edited_scene_root() != level:
		print("Error: Level not current root scene")
		return
	
	level.nav_zone_map.visible = true
	for nav_floor in level.nav_zone_map.get_children():
		for nav_zone_holder : NavZoneHolder in nav_floor.get_children():
			if nav_zone_holder.configs == zone:
				print("found it")
				EditorInterface.get_selection().clear()
				EditorInterface.get_selection().add_node(nav_zone_holder)
				return