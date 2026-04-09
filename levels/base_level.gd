class_name BaseLevel
extends Node3D

var is_player_turn := true

var active_unit

@onready var _unit : Unit = %Unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.tile_left_clicked.connect(_on_tile_left_clicked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_left_clicked(tile_position : Vector3):
	_unit.tile_position = tile_position
	_unit.snap_to_position()
