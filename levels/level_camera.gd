class_name LevelCamera
extends Node3D

var y_level := 0
var zoom_offset := 8:
	set(val):
		if val < 3:
			zoom_offset = 3
		elif val >  16:
			zoom_offset = 16
		else:
			zoom_offset = val

@onready var _camera : Camera3D = %Camera3D

func jump_to_point(point: Vector3i):
	y_level = point.y
	point.y *= 4
	global_position = point

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('y_up'):
		y_level += 1
		global_position.y = y_level * 4

	elif Input.is_action_just_pressed('y_down'):
		y_level -= 1
		global_position.y = y_level * 4

	elif Input.is_action_pressed('camera_pivot'):
		if event is InputEventMouseMotion and event.relative.x != 0:
			rotation.y -= (event.relative.x / 100)

	elif Input.is_action_pressed('camera_pan'):
		if event is InputEventMouseMotion and event.relative != Vector2.ZERO:
			global_position += Vector3(event.relative.x / 10, 0, event.relative.y / 10).rotated(Vector3.UP, rotation.y + 0.785)
	
	elif Input.is_action_just_pressed('zoom_in'):
		zoom_offset -= 1
		_camera.position = Vector3.ONE * zoom_offset
	
	elif Input.is_action_just_pressed('zoom_out'):
		zoom_offset += 1
		_camera.position = Vector3.ONE * zoom_offset