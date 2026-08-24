@tool
## A level for one match between player and enemy to take place in.
class_name Level
extends Node3D

static var current_level : Level

## Logic module for handling the enemy's awareness of the player's units.
var enemy_awareness := EnemyTeamAwarenessModule.new()

## Boolean tracking whether or not it is currently the player's turn.
var is_player_turn := true

## The currently active unit, whether a [FriendlyUnit] or an [EnemyUnit].
var active_unit : Unit:
	set(val):
		active_unit = val
		level_camera.fix_to_actor(val)
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
		return is_player_turn and active_unit and !active_unit.is_using_skill and !active_unit.is_moving

@onready var _friendlies_node := %Friendlies
@onready var _enemies_node := %Enemies
@onready var movement_system : MovementSystem = %MovementSystem
@onready var nav_map : NavigableGridMap = %NavigableGridMap
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var level_camera : LevelCamera = %LevelCamera
@onready var state_machine : StateMachine = %StateMachine
@onready var match_ui : MatchUI = %MatchUi
@onready var target_retical : Sprite3D = %TargetRetical
@onready var nav_zone_map : NavZoneMap = %NavZoneMap
@onready var geometry : Node3D = %Geometry

func _ready() -> void:
	if !Engine.is_editor_hint():
		nav_zone_map.visible = false
		Events.skill_armed.connect(_on_skill_armed)
		Events.skill_disarmed.connect(_on_skill_disarmed)
		nav_map.setup_astar_grid()
		current_level = self
		ConsoleEvents.command_submitted.connect(func (command_name, _parameters):
			if command_name == "exit":
				get_tree().quit()
		)


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


## Update the active unit to a given actor.
func set_active_unit(unit : Unit):
	if unit.unit_status != Unit.Status.DEAD:
		if active_unit:
			active_unit.deactivate()
		active_unit = unit
		if active_unit: 
			active_unit.activate()


## Returns the NavZoneHolder a given position is in.
func get_zone_from_position(pos : Vector3i) -> NavZone:
	for zone_holder : NavZoneHolder in nav_zone_map.get_child(pos.y).get_children():
		if zone_holder.configs.has_point(pos):
			return zone_holder.configs
	return null


## Generates an array of positions to visit in pursuit of a fleeing FriendlyUnit, in order, based on that unit's last known position.
func get_likely_path(pursuer_position : Vector3i, last_known_position : Vector3i, pursuit_depth := 6) -> Array[Vector3i]:
	var result : Array[Vector3i] = []
	var starting_zone = get_zone_from_position(pursuer_position)
	var last_known_zone = get_zone_from_position(last_known_position)
	var banned_zones : Array[NavZone] = [last_known_zone, starting_zone]
	var current_zone = last_known_zone
	var current_position = last_known_position

	# Update this with zones passed but not taken
	var bypassed_zones : Array[Array] = []

	for i in range(pursuit_depth):
		# Create a separate function which returns a full list of exit
		# Find the closest exit and get its zone, removing that exit from the full list
		# Additionally, filter the remainder of the list for exits which do not lead to the same zone as the closest exit.
		# Add the rest of the list to the bypassed zones list.
		var next_exit : NavZoneExit = current_zone.get_semirandom_exit(current_position, banned_zones)
		if !next_exit:
			return result
		current_zone = load(next_exit.to_zone_uid)
		current_position = next_exit.board_position
		result.append(current_zone.get_nearest_point(current_position))
		banned_zones.append(current_zone)

	return result


## Cycle the active unit to the next in the list.
func cycle_active_unit():
	var faction : Array
	if is_player_turn:
		faction = live_friendlies
	else:
		faction = live_enemies
	if active_unit:
		var index = faction.find(active_unit) + 1
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