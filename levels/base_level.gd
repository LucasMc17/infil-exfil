class_name BaseLevel
extends Node3D

var is_player_turn := true

var active_unit : Unit:
	set(val):
		active_unit = val
		level_camera.fix_to_actor(val)

var friendlies : Array:
	get():
		return _friendlies_node.get_children()

var enemies : Array:
	get():
		return _enemies_node.get_children()

var enemy_awareness := EnemyTeamAwarenessModule.new()

## TODO: While this works to stop a unit from moving into an occupied space, it does not stop them pathing directly through other units.
## Naive solution would be to regen A* grid after every Unit move. But I think it could get costly. Other idea: Can I manually clear a tile's connections when moved into?
## Then maybe keep a queue of tiles to be "repaired" after every move, unless they are still occupied. Maybe something there.
var occupied_map : Dictionary[Vector3, bool]:
	get():
		var result : Dictionary[Vector3, bool] = {}
		for friendly : FriendlyUnit in friendlies:
			result[friendly.tile_position as Vector3] = true
		for enemy : Unit in enemies:
			result[enemy.tile_position as Vector3] = true
		return result

@onready var nav_map : NavigableGridMapV2 = %NavigableGridMapV2
@onready var cell_highlighter : CellHighlighter = %CellHighlighter
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var _friendlies_node := %Friendlies
@onready var _enemies_node := %Enemies
@onready var level_camera : LevelCamera = %LevelCamera
@onready var state_machine : StateMachine = %StateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_map.setup_astar_grid()
	World.level = self


func set_active_unit(unit : Unit):
	if active_unit:
		active_unit.deactivate()
	active_unit = unit
	active_unit.activate()
	if active_unit.can_move:
		var valid_moves = nav_map.get_all_valid_moves(unit.tile_position, unit.max_movement)
		unit.set_valid_moves(valid_moves)
		cell_highlighter.highlighted_cells = valid_moves


func cycle_active_unit():
	var faction = friendlies if is_player_turn else enemies
	if active_unit:
		var index = faction.find(active_unit) + 1
		if index < faction.size():
			set_active_unit(faction[index])
		else:
			set_active_unit(faction[0])
	else:
		set_active_unit(faction[0])


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