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
var target : Node3D

@onready var _camera : Camera3D = %Camera3D
@onready var _y_pivot := %YPivot
@onready var _x_pivot := %XPivot

func jump_to_point(point: Vector3i):
	unfix()
	y_level = point.y
	_lerp_target = NavigableGridMapV2.convert_grid_to_global_position(point, true)


func fix_to_actor(actor : Node3D):
	target = actor


func unfix():
	target = null


func pan_camera(mouse_motion : Vector2):
	unfix()
	if mouse_motion != Vector2.ZERO:
		_lerp_target += Vector3(-mouse_motion.x / 50, 0, -mouse_motion.y / 50).rotated(Vector3.UP, _y_pivot.rotation.y)


func shift_camera_y(up : bool):
	unfix()
	if up:
		y_level += 1
	else:
		y_level -= 1
	_lerp_target.y = y_level * 4


func pivot_camera(mouse_motion : Vector2):
	if mouse_motion.x != 0:
		_y_pivot.rotation.y -= (mouse_motion.x / 100)
	if mouse_motion.y != 0:
		_x_pivot.rotation.x = clamp((_x_pivot.rotation.x - mouse_motion.y / 100), deg_to_rad(MIN_X_PIVOT), deg_to_rad(MAX_X_PIVOT))


func zoom_camera(inward : bool):
	if inward:
		zoom_offset -= 1
	else:
		zoom_offset += 1
	_camera.position.z =  zoom_offset + 12


func _process(_delta: float) -> void:
	if target:
		_lerp_target = target.global_position
		y_level = round(target.global_position.y / 4)
	global_position = lerp(global_position, _lerp_target, 0.15)
