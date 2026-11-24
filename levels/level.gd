@tool
## A level for one match between player and enemy to take place in.
@icon("uid://c8e3v8bomdmq6")
class_name Level
extends Node3D

## The currently active level.
static var current : Level

## Logic module for handling the enemy's awareness of the player's units.
var enemy_awareness := EnemyTeamAwarenessModule.new()
## The alarm system for this level.
var alarm := Alarm.new()

## Boolean tracking whether or not it is currently the player's turn.
var is_player_turn := true

## The currently armed skill.
var armed_skill : Skill

## All [FriendlyUnit]s in the level.
var all_friendlies : Array[FriendlyUnit]:
	get():
		var result : Array[FriendlyUnit] = []
		var true_friendlies = _friendlies_node.get_children()
		for friendly in true_friendlies:
			if friendly is FriendlyUnit:
				result.append(friendly)
		return result

## All still alive (not dead or unconscious) [FriendlyUnit]s in the level.
var live_friendlies : Array[FriendlyUnit]:
	get():
		var result : Array[FriendlyUnit] = []
		var true_friendlies = _friendlies_node.get_children()
		for friendly in true_friendlies:
			if friendly is FriendlyUnit and friendly.unit_status != Unit.Status.DEAD and friendly.unit_status != Unit.Status.UNCONSCIOUS:
				result.append(friendly)
		return result

## All [EnemyUnit]s in the level.
var all_enemies : Array[EnemyUnit]:
	get():
		var result : Array[EnemyUnit] = []
		var true_enemies = _enemies_node.get_children()
		for enemy in true_enemies:
			if enemy is EnemyUnit:
				result.append(enemy)
		return result

## All still alive (not dead or unconscious) [EnemyUnit]s in the level.
var live_enemies : Array[EnemyUnit]:
	get():
		var result : Array[EnemyUnit] = []
		var true_enemies = _enemies_node.get_children()
		for enemy in true_enemies:
			if enemy is EnemyUnit and enemy.unit_status != Unit.Status.DEAD and enemy.unit_status != Unit.Status.UNCONSCIOUS:
				result.append(enemy)
		return result

## All [Unit]s in the level, including both friendlies and enemies.
var all_units : Array[Unit]:
	get():
		var result : Array[Unit] = []
		for friendly in all_friendlies:
			if friendly is Unit:
				result.append(friendly)
		for enemy in all_enemies:
			if enemy is Unit:
				result.append(enemy)
		return result

## All still alive (not dead or unconscious) [Unit]s in the level, including both friendlies and enemies.
var live_units : Array[Unit]:
	get():
		var result : Array[Unit] = []
		for friendly in all_friendlies:
			if friendly is Unit and friendly.unit_status != Unit.Status.DEAD and friendly.unit_status != Unit.Status.UNCONSCIOUS:
				result.append(friendly)
		for enemy in all_enemies:
			if enemy is Unit and enemy.unit_status != Unit.Status.DEAD and enemy.unit_status != Unit.Status.UNCONSCIOUS:
				result.append(enemy)
		return result

## Whether or not to completely block the player's game play inputs, such as when a unit is moving.
var allow_inputs : bool:
	get():
		return is_player_turn and Unit.active_unit and !Unit.active_unit.is_using_skill and !Unit.active_unit.is_moving

@onready var _friendlies_node := %Friendlies
@onready var _enemies_node := %Enemies
@onready var movement_system : MovementSystem = %MovementSystem
@onready var nav_map : NavigableGridMap = %NavigableGridMap
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var level_camera : LevelCamera = %LevelCamera
@onready var state_machine : StateMachine = %StateMachine
@onready var match_ui : MatchUI = %MatchUi
@onready var target_retical : Sprite3D = %TargetRetical
@onready var nav_system : NavSystem = %NavSystem
@onready var geometry : Node3D = %Geometry
@onready var _dialog_layer : Control = %DialogLayer
@onready var _soundscape : Soundscape = %Soundscape

static func test_player_awareness(enemy : EnemyUnit) -> void:
	var zone = current.nav_system.get_zone_from_position(enemy.board_position)
	for player in current.live_friendlies:
		if zone:
			var player_zone = current.nav_system.get_zone_from_position(player.board_position)
			if player_zone == zone:
				enemy.awareness.player_aware = true
				print('in zone')
				return
		if player.board_position.distance_to(enemy.board_position) <= 3.0:
			enemy.awareness.player_aware = true
			print('within 3 m')
			return
		if player.seen_zone.get_visibility_of_seen_zone(enemy.seen_zone):
			enemy.awareness.player_aware = true
			print('can see')
			return
	
	print('not aware')
	enemy.awareness.player_aware = false


func _ready() -> void:
	if !Engine.is_editor_hint():
		nav_system.visible = false
		Events.skill_armed.connect(_on_skill_armed)
		Events.skill_disarmed.connect(_on_skill_disarmed)
		Events.unit_spoke.connect(_on_unit_spoke)
		nav_map.setup_astar_grid()
		ConsoleEvents.command_submitted.connect(func (command_name, _parameters):
			if command_name == "exit":
				get_tree().quit()
		)
		current = self
		Events.level_loaded.emit()
		for enemy in all_enemies:
			test_player_awareness(enemy)


func _exit_tree() -> void:
	current = null


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('y_up') and state_machine.current_state.allow_cam_movement:
		level_camera.shift_camera_y(true)

	elif Input.is_action_just_pressed('y_down') and state_machine.current_state.allow_cam_movement:
		level_camera.shift_camera_y(false)

	elif Input.is_action_pressed('camera_pivot'):
		if event is InputEventMouseMotion and event.relative != Vector2.ZERO:
			level_camera.pivot_camera(event.relative)

	elif Input.is_action_pressed('camera_pan'):
		if state_machine.current_state.allow_cam_movement and event is InputEventMouseMotion and event.relative != Vector2.ZERO:
			level_camera.pan_camera(event.relative)
	
	elif Input.is_action_just_pressed('zoom_in'):
		level_camera.zoom_camera(true)
	
	elif Input.is_action_just_pressed('zoom_out'):
		level_camera.zoom_camera(false)
	
	elif Input.is_action_just_pressed('escape'):
		DebugConsole.log("Pausing")
	
	elif Input.is_action_just_pressed('force_exit'):
		get_tree().quit()


func make_sound(pos : Vector3i, sound_res : Sound, exclude : Array[EnemyUnit] = []) -> void:
	_soundscape.make_sound(pos, sound_res, exclude)


## Update the active unit to a given actor.
func set_active_unit(unit : Unit):
	if unit.unit_status != Unit.Status.DEAD:
		if Unit.active_unit:
			Unit.active_unit.deactivate()
		Unit.active_unit = unit
		if Unit.active_unit: 
			Unit.active_unit.activate()


## Cycle the active unit to the next in the list.
func cycle_active_unit():
	var faction : Array
	if is_player_turn:
		faction = live_friendlies
	else:
		faction = live_enemies
	if Unit.active_unit:
		var index = faction.find(Unit.active_unit) + 1
		if index < faction.size():
			set_active_unit(faction[index])
		else:
			set_active_unit(faction[0])
	else:
		set_active_unit(faction[0])


## Test the theoretical line of sight from one global position to another. When a specific target is provided, the function will only return true if the ray's collider is that target. When one is not provided, it will only return true if there is no collider.
func test_line_of_sight(start_position : Vector3, target_position : Vector3, expected_target : Node3D = null) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(start_position, target_position, 1 + 2 + 4)
	var collision = get_world_3d().direct_space_state.intersect_ray(ray)
	if expected_target:
		return collision and collision.collider == expected_target
	else:
		return collision and !collision.collider


func _on_skill_armed(skill : Skill) -> void:
	if armed_skill:
		armed_skill.disarm()
		match_ui.disarm_skill_ui()
	armed_skill = skill
	armed_skill.arm()
	match_ui.arm_skill_ui(armed_skill)


func _on_skill_disarmed() -> void:
	if armed_skill:
		armed_skill.disarm()
		match_ui.disarm_skill_ui()
	armed_skill = null


func _on_unit_spoke(unit : Unit, message : String) -> void:
	var line : DialogLine = DialogLine.new_line(unit, message)
	_dialog_layer.add_child(line)