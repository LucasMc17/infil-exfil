@tool
## The UI to display in the dock when a level has succesfully loaded, with or without NavZones already saved.
class_name LevelLoadedUI
extends CenterContainer

signal zone_edit_requested(zone : NavZone)

@onready var _nav_zone_button : Button = %NewZoneButton
@onready var _name_input : LineEdit = %ZoneName
@onready var _file_input : LineEdit = %FileName


## Whether or not this UI screen is active.
var active := false
## The level that was loaded.
var level : Level

func _ready() -> void:
	_nav_zone_button.pressed.connect(_new_zone)
	_name_input.text_changed.connect(_on_name_input_changed)


## Runs when the UI is loaded after detecting a level.
func activate(loaded : Level) -> void:
	active = true
	visible = true
	level = loaded
	_nav_zone_button.disabled = false


## Runs when the UI is unloaded for any reason.
func deactivate() -> void:
	active = false
	visible = false
	level = null
	_nav_zone_button.disabled = true
	_name_input.text = ''
	_file_input.text = ''


func _process(_delta: float) -> void:
	if active:
		NavPaintUtilities.update_grid_map_plugin()
		if NavPaintUtilities.grid_map_editor_plugin.has_selection():
			var zone = level.nav_system.get_zone_from_position(NavPaintUtilities.grid_map_editor_plugin.get_selection().position)
			if zone:
				zone_edit_requested.emit(zone)


func _new_zone() -> void:
	if active:
		if !level:
			printerr("No level loaded")
			return
		if _name_input.text == "" or _file_input.text == "":
			printerr("Input a name and a file name for the new zone.")
			return
		var plugin = Utilities.get_grid_map_plugin()
		if !plugin:
			printerr("Not currently editing a level GridMap")
			return
		if !plugin.has_selection():
			printerr("No active selection")
			return
		var file_name = _file_input.text
		var new_file_path = level.scene_file_path.get_base_dir() + '/nav_zones/' + file_name + '.tres'
		if ResourceLoader.exists(new_file_path):
			printerr(new_file_path + ' already exists')
			return

		var selection = plugin.get_selection()
		var zone : NavZone = NavZone.new_zone_from_selection(_name_input.text, selection.position, Vector2i(selection.size.x + 1, selection.size.z + 1))
		print('saving ' + new_file_path + '...')
		ResourceSaver.save(zone, new_file_path)
		var loaded_file = ResourceLoader.load(new_file_path)
		level.nav_system.nav_zones.append(loaded_file)


func _on_name_input_changed(new_text : String) -> void:
	_file_input.text = new_text.to_snake_case()