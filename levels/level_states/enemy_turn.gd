extends LevelState

func _ready() -> void:
	allow_cam_movement = false
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)


func _process(delta: float) -> void:
	pass
	# if active:
		# level.level_camera.jump_to_point(level.active_unit.global_position)


func _on_enemy_turn_ended():
	cycle_enemy()


func enter(previous_state : State, ext : Dictionary):
	super(previous_state, ext)
	for enemy : EnemyUnit in level.enemies:
		enemy.reset()
	level.is_player_turn = false
	cycle_enemy()
	if level.active_unit.action_director.current_action:
		level.active_unit.action_director.current_action.begin(level.active_unit)
	else:
		level.active_unit.action_director.take_action_from_queue()
	# transition.call_deferred('PlayerTurn')


func cycle_enemy():
	var next_enemy_index = level.enemies.find_custom(func (unit): return unit.can_move)
	if next_enemy_index > -1:
		level.set_active_unit(level.enemies[next_enemy_index])
	else:
		transition('PlayerTurn')

