@tool
extends EditorPlugin

var _dock: EditorDock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	var dock_scene = preload("uid://ckwj7tuo85a75")

	_dock = EditorDock.new()
	_dock.add_child(dock_scene.instantiate())
	_dock.title = "Map Chunks"
	_dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_UL
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_ALL
	add_dock(_dock)

	


func _exit_tree() -> void:
	remove_dock(_dock)
	_dock.queue_free()