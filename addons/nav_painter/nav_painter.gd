@tool
extends EditorPlugin

var _dock: EditorDock

func _enter_tree() -> void:
	var dock_scene = preload("uid://cpaulkerjmwyc")

	_dock = EditorDock.new()
	_dock.add_child(dock_scene.instantiate())
	_dock.title = "Nav Painter"
	_dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_ALL
	add_dock(_dock)


func _exit_tree() -> void:
	remove_dock(_dock)
	_dock.queue_free()