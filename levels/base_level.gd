class_name BaseLevel
extends Node3D

var is_player_turn := true

var active_unit:
	set(val):
		active_unit = val
		level_camera.jump_to_point(active_unit.tile_position)

## TODO: While this works to stop a unit from moving into an occupied space, it does not stop them pathing directly through other units.
## Naive solution would be to regen A* grid after every Unit move. But I think it could get costly. Other idea: Can I manually clear a tile's connections when moved into?
## Then maybe keep a queue of tiles to be "repaired" after every move, unless they are still occupied. Maybe something there.
var occupied_map : Dictionary[Vector3, bool]:
	get():
		var result : Dictionary[Vector3, bool] = {}
		for friendly : FriendlyUnit in _friendlies.get_children():
			result[friendly.tile_position as Vector3] = true
		for enemy : Unit in _enemies.get_children():
			result[enemy.tile_position as Vector3] = true
		return result

@onready var nav_map : NavigableGridMapV2 = %NavigableGridMapV2
@onready var cell_highlighter : CellHighlighter = %CellHighlighter
@onready var click_handler : ClickHandler3D = %ClickHandler3D
@onready var _friendlies := %Friendlies
@onready var _enemies := %Enemies
@onready var level_camera : LevelCamera = %LevelCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav_map.setup_astar_grid()


func set_active_unit(unit : FriendlyUnit):
	active_unit = unit
	var valid_moves = nav_map.get_all_valid_moves(unit.tile_position, unit.max_movement)
	unit.set_valid_moves(valid_moves)

	cell_highlighter.highlighted_cells = valid_moves
