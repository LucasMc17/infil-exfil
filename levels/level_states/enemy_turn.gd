extends LevelState

func _ready() -> void:
	allow_cam_movement = false


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	for enemy : EnemyUnit in level.enemies:
		enemy.reset()
	level.is_player_turn = false
	cycle_enemy()
	if level.active_unit.decision_director.current_directive:
		level.active_unit.decision_director.current_directive.begin(level.active_unit)
	else:
		level.active_unit.decision_director.take_directive_from_queue()



func cycle_enemy() -> bool:
	if level.active_unit:
		_disconnect_active_unit_signals(level.active_unit)
	var next_enemy_index = level.enemies.find_custom(func (unit): return unit.can_move())
	if next_enemy_index > -1:
		level.set_active_unit(level.enemies[next_enemy_index])
		_connect_active_unit_signals(level.active_unit)
		return true
	else:
		transition('PlayerTurn')
		return false


func _cycle_if_finished_acting(unit : Unit) -> void:
	if !unit.can_move() and !unit.can_act():
		cycle_enemy()


func _disconnect_active_unit_signals(unit : Unit) -> void:
	if unit.finished_acting.is_connected(_cycle_if_finished_acting):
		unit.finished_acting.disconnect(_cycle_if_finished_acting)
	if unit.finished_moving.is_connected(_cycle_if_finished_acting):
		unit.finished_moving.disconnect(_cycle_if_finished_acting)
	if unit.forfeited_turn.is_connected(_cycle_if_finished_acting):
		unit.forfeited_turn.disconnect(_cycle_if_finished_acting)


func _connect_active_unit_signals(unit : Unit) -> void:
	unit.finished_acting.connect(_cycle_if_finished_acting)
	unit.finished_moving.connect(_cycle_if_finished_acting)
	unit.forfeited_turn.connect(_cycle_if_finished_acting)
