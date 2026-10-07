class_name UnitAwarenessInspector
extends PanelContainer

@onready var _level : DebugKVPair = %Level
@onready var _contact_point : DebugKVPair = %ContactPoint
@onready var _in_sight : DebugKVPair = %FriendliesInSight
@onready var _in_sight_buttons : VBoxContainer = %InSightButtons
@onready var _out_of_sight : DebugKVPair = %FriendliesOutOfSight
@onready var _out_of_sight_buttons : VBoxContainer = %OutOfSightButtons

var awareness : EnemyUnitAwarenessModule

func refresh(new_module : EnemyUnitAwarenessModule = null) -> void:
	if new_module:
		awareness = new_module
	if awareness:
		_level.value = EnemyUnitAwarenessModule.AwarenessLevel.find_key(awareness.awareness_level)
		if awareness.last_poc: 
			_contact_point.value = str(awareness.last_poc.position)
		else:
			_contact_point.value = "NONE"
		
		_in_sight.value = str(awareness.friendlies_in_sight.size())
		_out_of_sight.value = str(awareness.friendlies_out_of_sight.size())
		Utilities.clear_children(_in_sight_buttons)
		Utilities.clear_children(_out_of_sight_buttons)
		for sighting in awareness.friendlies_in_sight:
			var button = Button.new()
			button.text = sighting.friendly.name
			button.pressed.connect(func (): Level.current_level.level_camera.jump_to_point(sighting.friendly.global_position))
			_in_sight_buttons.add_child(button)
		for sighting in awareness.friendlies_out_of_sight:
			var button = Button.new()
			button.text = sighting.friendly.name
			button.pressed.connect(func (): Level.current_level.level_camera.jump_to_point(sighting.friendly.global_position))
			_out_of_sight_buttons.add_child(button)



func _on_contact_point_button_pressed() -> void:
	if awareness and awareness.last_poc:
		Level.current_level.level_camera.jump_to_point(NavigableGridMap.convert_grid_to_global_position(awareness.last_poc.position))


func _on_lose_alarm_button_pressed() -> void:
	if awareness:
		awareness.drop_guard()
