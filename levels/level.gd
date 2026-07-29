## A level for one match between player and enemy to take place in.
class_name BaseLevel
extends Node3D

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
@onready var path_marking_system : MovementSystem = %MovementSystem
@onready var nav_map : NavigableGridMap = %NavigableGridMap
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var level_camera : LevelCamera = %LevelCamera
@onready var state_machine : StateMachine = %StateMachine
@onready var match_ui : MatchUI = %MatchUi
@onready var target_retical : Sprite3D = %TargetRetical
@onready var _beacon_holder : Node3D = %BeaconHolder

func _ready() -> void:
	_beacon_holder.visible = false
	Events.skill_armed.connect(_on_skill_armed)
	Events.skill_disarmed.connect(_on_skill_disarmed)
	nav_map.setup_astar_grid()
	World.level = self
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