extends LevelState

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


func cycle_enemy() -> void:
	if !enemy_units.is_empty():
		var enemy = enemy_units.pop_front()
		level.set_active_unit(enemy)
		if enemy.decision_director.current_directive:
			enemy.decision_director.current_directive.begin(enemy)
		else:
			enemy.decision_director.take_directive_from_queue()
		await enemy.forfeited_turn
		DebugConsole.log([enemy, "ENEMY TURN ENDED"])
		cycle_enemy()
	else:
		transition('PlayerTurn')


func _cycle_if_finished_acting(unit : Unit) -> void:
	if !unit.can_move() and !unit.can_act():
		cycle_enemy()