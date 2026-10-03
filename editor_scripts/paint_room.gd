@tool
class_name PaintRoom
extends EditorScript

func _get_grid_map_plugin() -> GridMapEditorPlugin:
	var editor_root = EditorInterface.get_base_control().get_tree().root
	var grid_map_plugins = editor_root.find_children("", "GridMapEditorPlugin", true, false)

	if grid_map_plugins.is_empty():
		return null

	return grid_map_plugins[0]


func _set_grid_map_contents(grid_map : GridMap, cell_map : Dictionary[Vector3i, Vector2i]) -> void:
	grid_map.clear()
	for cell in cell_map.keys():
		var value = cell_map[cell]
		var item = value.x
		var rotation = value.y

		grid_map.set_cell_item(cell, item, rotation)


func _run() -> void:
	var grid_map_plugin = _get_grid_map_plugin()

	if !grid_map_plugin:
		printerr("COULD NOT FIND GRID MAP PLUGIN")

	var grid_map = grid_map_plugin.get_current_grid_map()
	if !grid_map:
		printerr("NO ACTIVE GRID MAP")

	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Paint Room")

	var old_cell_map : Dictionary[Vector3i, Vector2i] = {}
	for cell in grid_map.get_used_cells():
		old_cell_map[cell] = Vector2i(grid_map.get_cell_item(cell), grid_map.get_cell_item_orientation(cell))
	
	var new_cell_map : Dictionary[Vector3i, Vector2i] = old_cell_map.duplicate()
	var selection = grid_map_plugin.get_selection()
	var position = selection.position


	for z in selection.size.z + 1:
		position.x = selection.position.x
		for x in selection.size.x + 1:
			if z == 0:
				# Closest line
				if x == 0:
					# Closest right corner
					new_cell_map[position] = Vector2i(4, 0)
				elif x == selection.size.x:
					# Closest left corner
					new_cell_map[position] = Vector2i(4, 22)
				else:
					# Closest wall
					new_cell_map[position] = Vector2i(1, 0)
			elif z == selection.size.z:
				# Closest line
				if x == 0:
					# Furthest right corner
					new_cell_map[position] = Vector2i(4, 16)
				elif x == selection.size.x:
					# Furthest left corner
					new_cell_map[position] = Vector2i(4, 10)
				else:
					# Furthest wall
					new_cell_map[position] = Vector2i(1, 10)
			elif x == 0:
				# Rightmost wall
					new_cell_map[position] = Vector2i(1, 16)
			elif x == selection.size.x:
				# Leftmost wall
				new_cell_map[position] = Vector2i(1, 22)
			else:
				# Floor
				new_cell_map[position] = Vector2i(0, 0)
			position.x += 1
		position.z += 1

	undo_redo.add_do_method(self, "_set_grid_map_contents", grid_map, new_cell_map)
	undo_redo.add_undo_method(self, "_set_grid_map_contents", grid_map, old_cell_map)
	undo_redo.commit_action(true)
	