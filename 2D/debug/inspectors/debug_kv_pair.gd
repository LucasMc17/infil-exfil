@tool
class_name DebugKVPair
extends HBoxContainer

@export var key : String = "Key":
	set(val):
		key = val
		if key_label:
			key_label.text = key + ":"
@export var value : String = "Value":
	set(val):
		value = val
		if value_label:
			value_label.text = value

@onready var key_label : Label = %Key
@onready var value_label : Label = %Value

func _ready() -> void:
	key_label.text = key + ':'
	value_label.text = value
