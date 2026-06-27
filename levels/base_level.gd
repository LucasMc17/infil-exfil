## A level for one match between player and enemy to take place in.
class_name BaseLevel
extends Node3D

## Logic module for handling the usage of skills.
var skill_handler := SkillHandler.new()
## Logic module for handling the enemy's awareness of the player's units.
var enemy_awareness := EnemyTeamAwarenessModule.new()

## Boolean tracking whether or not it is currently the player's turn.
var is_player_turn := true

## The currently active unit, whether a [FriendlyUnit] or an [EnemyUnit].
var active_unit : Unit:
	set(val):
		active_unit = val
		level_camera.fix_to_actor(val)

## All [FriendlyUnit]s in the level.
var friendlies : Array[FriendlyUnit]:
	get():
		var result : Array[FriendlyUnit] = []
		var true_friendlies = _friendlies_node.get_children()
		for friendly in true_friendlies:
			if friendly is FriendlyUnit:
				result.append(friendly)
		return result

## All [EnemyUnit]s in the level.
var enemies : Array[EnemyUnit]:
	get():
		var result : Array[EnemyUnit] = []
		var true_enemies = _enemies_node.get_children()
		for enemy in true_enemies:
			if enemy is EnemyUnit:
				result.append(enemy)
		return result


## All [Unit]s in the level, including both friendlies and enemies.
var units : Array[Unit]:
	get():
		var result : Array[Unit] = []
		for friendly in friendlies:
			if friendly is Unit:
				result.append(friendly)
		for enemy in enemies:
			if enemy is Unit:
				result.append(enemy)
		return result

@onready var _friendlies_node := %Friendlies
@onready var _enemies_node := %Enemies
@onready var nav_map : NavigableGridMapV2 = %NavigableGridMapV2
@onready var cell_highlighter : CellHighlighter = %CellHighlighter
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var level_camera : LevelCamera = %LevelCamera
@onready var state_machine : StateMachine = %StateMachine
@onready var match_ui : MatchUI = %MatchUi
@onready var target_retical : Sprite3D = %TargetRetical

func _ready() -> void:
	nav_map.setup_astar_grid()
	World.level = self
	ConsoleEvents.command_submitted.connect(func (command_name, _parameters):
		if command_name == "exit":
			get_tree().quit()
	)


func _input(event: InputEvent) -> void:
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
		if World.targeting.armed_skill:
			Events.skill_disarmed.emit()
		else:
			DebugConsole.log("Pausing")
	
	elif Input.is_action_just_pressed('force_exit'):
		get_tree().quit()


## Update the active unit to a given actor.
func set_active_unit(unit : Unit):
	if active_unit:
		active_unit.deactivate()
	active_unit = unit
	if active_unit:
		active_unit.activate()


## Cycle the active unit to the next in the list.
func cycle_active_unit():
	var faction : Array
	if is_player_turn:
		faction = friendlies
	else:
		faction = enemies
	if active_unit:
		var index = faction.find(active_unit) + 1
		if index < faction.size():
			set_active_unit(faction[index])
		else:
			set_active_unit(faction[0])
	else:
		set_active_unit(faction[0])