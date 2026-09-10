class_name DebugUnitInfo
extends PanelContainer

@onready var _name_label : Label = %Name
@onready var _acting_state : DebugKVPair = %ActingState
@onready var _position : DebugKVPair = %Position
@onready var _level : DebugKVPair = %Level
@onready var _contact_point : DebugKVPair = %ContactPoint
@onready var _contact_point_button : Button = %ContactPointButton
@onready var _in_sight : DebugKVPair = %FriendliesInSight
@onready var _in_sight_buttons : VBoxContainer = %InSightButtons
@onready var _out_of_sight : DebugKVPair = %FriendliesOutOfSight
@onready var _out_of_sight_buttons : VBoxContainer = %OutOfSightButtons

var unit : EnemyUnit

func display_unit_info(u : EnemyUnit) -> void:
	unit = u
	visible = true

	_name_label.text = unit.name

	_acting_state.value = Unit.Status.find_key(unit.unit_status)
	_position.value = str(unit.board_position)

	_level.value = EnemyUnitAwarenessModule.AwarenessLevel.find_key(unit.awareness.awareness_level)
	if unit.awareness.last_poc:
		_contact_point.value = str(unit.awareness.last_poc.position)
		_contact_point_button.disabled = false
	else:
		_contact_point.value = "NONE"
		_contact_point_button.disabled = true
	
	_handle_button_list(unit.awareness.friendlies_in_sight, _in_sight, _in_sight_buttons)
	_handle_button_list(unit.awareness.friendlies_out_of_sight, _out_of_sight, _out_of_sight_buttons)


func _handle_button_list(friendly_sightings : Array[EnemyUnitAwarenessModule.FriendlySighting], label : DebugKVPair, list : VBoxContainer) -> void:
	label.value = str(friendly_sightings.size())
	for child in list.get_children():
		child.queue_free()
	for sighting in friendly_sightings:
		var button = Button.new()
		button.text = sighting.friendly.name
		button.pressed.connect(func (): Level.current_level.level_camera.jump_to_point(sighting.friendly.global_position))
		list.add_child(button)

	


func _on_contact_point_button_pressed() -> void:
	Level.current_level.level_camera.jump_to_point(NavigableGridMap.convert_grid_to_global_position(unit.awareness.last_poc.position))
