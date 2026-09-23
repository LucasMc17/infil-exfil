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
@onready var _current_directive : DebugKVPair = %CurrentDirective
@onready var _friendly_bodies : DebugKVPair = %FriendlyBodies
@onready var _enemy_bodies : DebugKVPair = %EnemyBodies
@onready var _friendly_body_buttons : VBoxContainer = %FriendlyBodyButtons
@onready var _enemy_body_buttons : VBoxContainer = %EnemyBodyButtons

var unit : EnemyUnit

func _ready() -> void:
	Events.request_update_unit_monitor.connect(_on_refresh_requested)

func display_unit_info(u : EnemyUnit) -> void:
	if u:
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
		
		_handle_sightings_button_list(unit.awareness.friendlies_in_sight, _in_sight, _in_sight_buttons)
		_handle_sightings_button_list(unit.awareness.friendlies_out_of_sight, _out_of_sight, _out_of_sight_buttons)
		_handle_bodies_button_list(unit.awareness.known_bodies, _friendly_bodies, _enemy_bodies, _friendly_body_buttons, _enemy_body_buttons)


		_current_directive.value = unit.decision_director.last_directive_name


func refresh() -> void:
	display_unit_info(unit)


func _handle_sightings_button_list(friendly_sightings : Array[EnemyUnitAwarenessModule.FriendlySighting], label : DebugKVPair, list : VBoxContainer) -> void:
	label.value = str(friendly_sightings.size())
	for child in list.get_children():
		child.queue_free()
	for sighting in friendly_sightings:
		var button = Button.new()
		button.text = sighting.friendly.name
		button.pressed.connect(func (): Level.current_level.level_camera.jump_to_point(sighting.friendly.global_position))
		list.add_child(button)


func _handle_bodies_button_list(bodies : Utilities.BodiesDict, friendly_label : DebugKVPair, enemy_label : DebugKVPair, friendly_list : VBoxContainer, enemies_list : VBoxContainer) -> void:
	friendly_label.value = str(bodies.friendlies.size())
	enemy_label.value = str(bodies.enemies.size())
	for child in friendly_list.get_children():
		child.queue_free()
	for child in enemies_list.get_children():
		child.queue_free()
	for friendly in bodies.friendlies.values():
		var button = Button.new()
		button.text = friendly.name
		button.pressed.connect(func(): Level.current_level.level_camera.jump_to_point(friendly.global_position))
		friendly_list.add_child(button)
	for enemy in bodies.enemies.values():
		var button = Button.new()
		button.text = enemy.name
		button.pressed.connect(func(): Level.current_level.level_camera.jump_to_point(enemy.global_position))
		enemies_list.add_child(button)


func _on_contact_point_button_pressed() -> void:
	Level.current_level.level_camera.jump_to_point(NavigableGridMap.convert_grid_to_global_position(unit.awareness.last_poc.position))


func _on_refresh_requested(u : EnemyUnit) -> void:
	if u == unit:
		refresh()