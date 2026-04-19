@tool
extends EditorPlugin

const DEBUG_LABEL = preload("res://addons/debug_label_3d/debug_label.gd")

func _enable_plugin() -> void:
	add_custom_type("DebugLabel", "Sprite3D", DEBUG_LABEL, null)


func _disable_plugin() -> void:
	remove_custom_type("DebugLabel")
