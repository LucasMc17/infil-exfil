extends LevelState

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = true
	Events.player_turn_ended.connect(_on_player_turn_ended)


func input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('cycle_unit'):
		level.cycle_active_unit()
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
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
			if level.active_unit and level.active_unit.potential_moves.has(coords):
				level.active_unit.move_to_position(coords)
				level.level_camera.jump_to_point(coords)
				level.cell_highlighter.highlighted_cells = []


func _on_player_turn_ended():
	transition('EnemyTurn')


func exit():
	super()
	Events.player_turn_ended.disconnect(_on_player_turn_ended)