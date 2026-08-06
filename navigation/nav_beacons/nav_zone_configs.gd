@tool
class_name NavZoneConfigFile
extends Resource

# @export var base_position : Vector3i:
# 	set(val):
# 		base_position = val
# 		if Engine.is_editor_hint():
# 			emit_changed()

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

@export var exits : Array[Vector2i]:
	set(val):
		exits = val
		if Engine.is_editor_hint():
			emit_changed()