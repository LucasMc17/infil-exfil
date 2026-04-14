extends LevelState

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = false
	level.cycle_active_unit()
	level.active_unit.state_machine.current_state.take_turn()
