extends LevelState

func input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked = level.click_handler.get_clicked_object()
		if clicked == null:
			return
		var clicked_object = clicked.collider
		if clicked_object is FriendlyUnit:
			level.set_active_unit(clicked_object)
		if clicked_object is NavigableGridMapV2:
			var real_position = clicked.position
			# Moves the considered position up slightly to avoid misidentifying y layer.
			real_position.y += 0.1
			var coords = clicked_object.local_to_map(clicked_object.to_local(real_position))
			print(coords)
			if level.active_unit and level.active_unit.potential_moves.has(coords):
				level.active_unit.tile_position = coords
				level.active_unit.snap_to_position()

