extends LevelState

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = true
	for friendly : FriendlyUnit in level.live_friendlies:
		friendly.reset()
	level.set_active_unit.call_deferred(level.live_friendlies[0])
	Events.player_turn_ended.connect(_on_player_turn_ended)


func input(_event : InputEvent):
	if level.allow_inputs:
		if Input.is_action_just_pressed('cycle_unit'):
			level.cycle_active_unit()


func unhandled_input(event: InputEvent) -> void:
	if active:
		if event is InputEventMouse:
			var mouse_target = level.click_handler.get_clicked_object()
			if mouse_target == null:
				level.movement_system.clear_hovered_path()
				return
			var target_object = mouse_target.collider
			if target_object is not NavigableGridMap:
				level.movement_system.clear_hovered_path()
				return
			else:
				var real_position = mouse_target.position
				real_position.y += 0.1
				var coords = target_object.local_to_map(target_object.to_local(real_position))
				if Level.current_level.allow_inputs and level.movement_system.viable_moves.has(coords):
					if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and level.movement_system.path.size() >= 1:
						Unit.active_unit.movement_machine.current_state.transition('Sneak', { "path": Level.current_level.movement_system.path })
						level.movement_system.wipe_planned_path()
					elif event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT and level.movement_system.hovered_path.size() >= 1:
						pass
						level.movement_system.place_waymarker(coords)
					elif event is InputEventMouseMotion:
						level.movement_system.mark_hovered_path(coords)
				else:
					level.movement_system.clear_hovered_path()


func _on_player_turn_ended():
	transition('EnemyTurn')


func exit():
	super()
	Events.player_turn_ended.disconnect(_on_player_turn_ended)
