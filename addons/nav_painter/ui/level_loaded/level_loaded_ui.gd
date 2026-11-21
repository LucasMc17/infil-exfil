@tool
## The UI to display in the dock when a level has succesfully loaded, with or without NavZones already saved.
class_name LevelLoadedUI
extends CenterContainer

signal zone_edit_requested(zone : NavZone)


var active := false
## The level that was loaded.
var level : Level

## Runs when the UI is loaded after detecting a level.
func activate(loaded : Level) -> void:
	active = true
	visible = true
	level = loaded


## Runs when the UI is unloaded for any reason.
func deactivate() -> void:
	active = false
	visible = false
	level = null


func _process(_delta: float) -> void:
	if active:
		NavPaintUtilities.update_grid_map_plugin()
		if NavPaintUtilities.grid_map_editor_plugin.has_selection():
			var zone = level.nav_system.get_zone_from_position(NavPaintUtilities.grid_map_editor_plugin.get_selection().position)
			if zone:
				zone_edit_requested.emit(zone)

