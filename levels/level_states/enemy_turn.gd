extends LevelState

func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	level.is_player_turn = false
	level.cycle_active_unit()
