extends LevelState

## The list of enemies to cycle through during the enemy turn.
var enemy_units : Array

func _ready() -> void:
	allow_cam_movement = false


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	enemy_units = level.live_enemies
	for enemy : EnemyUnit in enemy_units:
		enemy.reset()
	level.is_player_turn = false
	cycle_enemy()


## Change the active unit from the current enemy to the next in the list. If there is no next enemy in the list, cycle back to the player turn.
func cycle_enemy() -> void:
	if !enemy_units.is_empty():
		var enemy = enemy_units.pop_front()
		level.set_active_unit(enemy)
		# NOTE: There's a decision to be made about how much I like/trust awaits here, but this works to give us some breathng room between the camera movement and the enemy action.
		await get_tree().create_timer(1.0).timeout
		if enemy.decision_director.current_directive:
			enemy.decision_director.current_directive.begin(enemy)
		else:
			enemy.decision_director.take_directive_from_queue()
		await enemy.forfeited_turn
		cycle_enemy()
	else:
		transition.call_deferred('PlayerTurn')
