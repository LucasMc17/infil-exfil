extends LevelState

func _ready() -> void:
	allow_cam_movement = false


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = false
	level.cycle_active_unit()
	level.active_unit.state_machine.current_state.take_turn()
	# transition.call_deferred('PlayerTurn')


func _process(delta: float) -> void:
	if active:
		print(level.active_unit)
		# level.level_camera.jump_to_point(level.active_unit.global_position)

