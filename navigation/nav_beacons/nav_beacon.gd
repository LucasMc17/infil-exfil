@tool
class_name NavBeacon
extends Node3D

const CONNECTION_SCENE = preload('./beacon_connection.tscn')

@export var connections : Array[NavBeacon]:
	set(val):
		print('setting!!!')
		connections = val
		_connect()

@onready var _label : Label3D = %Label3D
@onready var connections_holder : Node3D = %ConnectionsHolder

func _connect():
	if Engine.is_editor_hint():
		for child in connections_holder.get_children():
			child.queue_free()
		for connection in connections:

			var conn_scene = CONNECTION_SCENE.instantiate()
			conn_scene.start_point = position
			conn_scene.end_point = connection.position
			connections_holder.add_child(conn_scene)

func _ready() -> void:
	_label.text = name
	_connect()
