extends LevelState

func _ready() -> void:
	allow_cam_movement = false


func _on_enemy_finished_moving(_unit):
	if cycle_enemy():
		if level.active_unit.decision_director.current_directive:
			level.active_unit.decision_director.current_directive.begin(level.active_unit)
		else:
			level.active_unit.decision_director.take_directive_from_queue()


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	Events.enemy_finished_moving.connect(_on_enemy_finished_moving)
	for enemy : EnemyUnit in level.enemies:
		enemy.reset()
	level.is_player_turn = false
	cycle_enemy()
	if level.active_unit.decision_director.current_directive:
		level.active_unit.decision_director.current_directive.begin(level.active_unit)
	else:
		level.active_unit.decision_director.take_directive_from_queue()
	# transition.call_deferred('PlayerTurn')


func exit():
	Events.enemy_finished_moving.disconnect(_on_enemy_finished_moving)


func cycle_enemy() -> bool:
	var next_enemy_index = level.enemies.find_custom(func (unit): return unit.can_move())
	if next_enemy_index > -1:
		level.set_active_unit(level.enemies[next_enemy_index])
		return true
	else:
		transition('PlayerTurn')
		return false

