class_name LevelCamera
extends Node3D

const MIN_X_PIVOT := -90
const MAX_X_PIVOT := 0

var y_level := 0
var zoom_offset := 0:
	set(val):
		if val < -10:
			zoom_offset = -10
		elif val >  15:
			zoom_offset = 15
		else:
			zoom_offset = val
var _lerp_target := global_position

@onready var _camera : Camera3D = %Camera3D
@onready var _y_pivot := %YPivot
@onready var _x_pivot := %XPivot

func jump_to_point(point: Vector3i):
	y_level = point.y
	point.y *= 4
	_lerp_target = point


func _process(_delta: float) -> void:
	global_position = lerp(global_position, _lerp_target, 0.15)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('y_up'):
		y_level += 1
		_lerp_target.y = y_level * 4

	elif Input.is_action_just_pressed('y_down'):
		y_level -= 1
		_lerp_target.y = y_level * 4

	elif Input.is_action_pressed('camera_pivot'):
		if event is InputEventMouseMotion and event.relative.x != 0:
			_y_pivot.rotation.y -= (event.relative.x / 100)
		if event is InputEventMouseMotion and event.relative.y != 0:
			_x_pivot.rotation.x = clamp((_x_pivot.rotation.x - event.relative.y / 100), deg_to_rad(MIN_X_PIVOT), deg_to_rad(MAX_X_PIVOT))

	elif Input.is_action_pressed('camera_pan'):
		if event is InputEventMouseMotion and event.relative != Vector2.ZERO:
			_lerp_target += Vector3(-event.relative.x / 20, 0, -event.relative.y / 20).rotated(Vector3.UP, _y_pivot.rotation.y)
	
	elif Input.is_action_just_pressed('zoom_in'):
		zoom_offset -= 1
		_camera.position.z =  zoom_offset + 12
	
	elif Input.is_action_just_pressed('zoom_out'):
		zoom_offset += 1
		_camera.position.z =  zoom_offset + 12
