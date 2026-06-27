extends LevelState

## The list of enemies to cycle through during the enemy turn.
var enemy_units : Array

func _ready() -> void:
	allow_cam_movement = false


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	enemy_units = level.enemies
	for enemy : EnemyUnit in enemy_units:
		enemy.reset()
	level.is_player_turn = false
	cycle_enemy()


## Change the active unit from the current enemy to the next in the list. If there is no next enemy in the list, cycle back to the player turn.
func cycle_enemy() -> void:
	if !enemy_units.is_empty():
		var enemy = enemy_units.pop_front()
		level.set_active_unit(enemy)
		if enemy.decision_director.current_directive:
			enemy.decision_director.current_directive.begin(enemy)
		else:
			enemy.decision_director.take_directive_from_queue()
		await enemy.forfeited_turn
		cycle_enemy()
	else:
		transition('PlayerTurn')
