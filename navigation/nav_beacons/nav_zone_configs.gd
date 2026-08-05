@tool
class_name NavZoneConfigFile
extends Resource

@export var areas : Array[Rect2i]:
	set(val):
		areas = val
		if Engine.is_editor_hint():
			emit_changed()

@export var points : Array[Vector2i]:
	set(val):
		points = val
		if Engine.is_editor_hint():
			emit_changed()