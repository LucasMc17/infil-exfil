extends LevelState

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = true
	for friendly : FriendlyUnit in level.friendlies:
		friendly.reset()
	level.set_active_unit.call_deferred(level.friendlies[0])
	Events.player_turn_ended.connect(_on_player_turn_ended)


func input(_event : InputEvent):
	if active:
		if Input.is_action_just_pressed('cycle_unit'):
			level.cycle_active_unit()


func unhandled_input(event: InputEvent) -> void:
	if active:
		if event is InputEventMouse:
			var mouse_target = level.click_handler.get_clicked_object()
			if mouse_target == null:
				level.path_marking_system.clear_hovered_path()
				return
			var target_object = mouse_target.collider
			if target_object is not NavigableGridMap:
				level.path_marking_system.clear_hovered_path()
				return
			else:
				var real_position = mouse_target.position
				real_position.y += 0.1
				var coords = target_object.local_to_map(target_object.to_local(real_position))
				# if level.active_unit and level.active_unit.can_move() and level.active_unit.potential_moves.has(coords):
				if level.path_marking_system.viable_moves.has(coords):
					if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and level.path_marking_system.path.size() >= 1:
						level.active_unit.movement_machine.current_state.transition('Sneak', { "path": World.level.path_marking_system.path })
						level.path_marking_system.wipe_planned_path()
					elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and level.path_marking_system.hovered_path.size() >= 1:
						level.path_marking_system.place_waymarker(coords)
					elif event is InputEventMouseMotion:
						level.path_marking_system.mark_hovered_path(coords)
				else:
					level.path_marking_system.clear_hovered_path()


func _on_player_turn_ended():
	transition('EnemyTurn')


func exit():
	super()
	Events.player_turn_ended.disconnect(_on_player_turn_ended)
