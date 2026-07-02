## A camera specifically designed for use in a level. It can pivot on two axes around a focal point, track an actor, jump to a specific point, zoom in, zoom out, pan and ascend or descene in even increments.
class_name LevelCamera
extends Node3D

## The lower limit of the camera's x-pivot.
const MIN_X_PIVOT := -90
## The upper limit of the camera's x-pivot.
const MAX_X_PIVOT := 0

## The zoom level of the camera. Capped between 10 meters zoomed in from the starting position, and 15 meters zoomed out from the starting position.
var zoom_offset := 0:
	set(val):
		if val < -10:
			zoom_offset = -10
		elif val >  15:
			zoom_offset = 15
		else:
			zoom_offset = val
## If assigned, the actor in 3D space to follow. The Camera will automatically lerp towards this Node's position.
var target : Node3D

@onready var _lerp_target := global_position
@onready var _camera : Camera3D = %Camera3D
@onready var _y_pivot := %YPivot
@onready var _x_pivot := %XPivot

func _process(_delta: float) -> void:
	if target:
		_lerp_target = target.global_position
	global_position = lerp(global_position, _lerp_target, 0.15)


## Jump the camera to a specific point in 3D space.
func jump_to_point(point: Vector3i):
	unfix()
	_lerp_target = NavigableGridMap.convert_grid_to_global_position(point, true)


## Fix the camera to an actor in 3D space.
func fix_to_actor(actor : Node3D):
	target = actor


## Unfix the camera from it's current target actor.
func unfix():
	target = null


## Pan the camera along the X/Y plane, in accordance with a Vector2 indicating relative motion.
func pan_camera(mouse_motion : Vector2):
	unfix()
	if mouse_motion != Vector2.ZERO:
		_lerp_target += Vector3(-mouse_motion.x / 50, 0, -mouse_motion.y / 50).rotated(Vector3.UP, _y_pivot.rotation.y)


## Move the camera up or down one level on the nav grid.
func shift_camera_y(up : bool):
	unfix()
	if up:
		var current_grid_y = floor(_lerp_target.y / NavigableGridMap.CELL_SIZE.y)
		_lerp_target.y = (current_grid_y + 1) * NavigableGridMap.CELL_SIZE.y
	else:
		var current_grid_y = ceil(_lerp_target.y / NavigableGridMap.CELL_SIZE.y)
		_lerp_target.y = (current_grid_y - 1) * NavigableGridMap.CELL_SIZE.y
	DebugConsole.log(_lerp_target.y)


## Pivot the camera around the focal point, in accordance with a Vector2 indicating relative motion.
func pivot_camera(mouse_motion : Vector2):
	if mouse_motion.x != 0:
		_y_pivot.rotation.y -= (mouse_motion.x / 100)
	if mouse_motion.y != 0:
		_x_pivot.rotation.x = clamp((_x_pivot.rotation.x - mouse_motion.y / 100), deg_to_rad(MIN_X_PIVOT), deg_to_rad(MAX_X_PIVOT))


## Zoom the camera in or out from the focal point.
func zoom_camera(inward : bool):
	if inward:
		zoom_offset -= 1
	else:
		zoom_offset += 1
	_camera.position.z =  zoom_offset + 12
