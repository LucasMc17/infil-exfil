class_name ActionDirector
extends Resource

var unit : EnemyUnit

var awareness : EnemyUnitAwarenessModule

var current_action : Action

var unaware_base_actions : Array[Action]
var alerted_base_actions : Array[Action]

var unaware_action_queue : Array[Action] = []
var alerted_action_queue : Array[Action] = []
var alarmed_action_queue : Array[Action] = []

var current_action_queue : Array[Action]:
	get():
		if awareness.is_unaware():
			return unaware_action_queue
		if awareness.is_alerted():
			return alerted_action_queue
		return alarmed_action_queue

func _init(u : EnemyUnit, a : EnemyUnitAwarenessModule) -> void:
	unit = u
	awareness = a

	unaware_base_actions = unit.unaware_base_actions
	alerted_base_actions = unit.alerted_base_actions


func take_action_from_queue():
	var next_action : Action
	if awareness.is_unaware():
		if unaware_action_queue.is_empty():
			unaware_action_queue = unaware_base_actions.duplicate()
		next_action = unaware_action_queue[0]
	elif awareness.is_alerted():
		if alerted_action_queue.is_empty():
			alerted_action_queue = alerted_action_queue.duplicate()
		next_action = alerted_action_queue[0]
	elif awareness.is_alarmed():
		if alarmed_action_queue.is_empty():
			_decide_alarmed_action()
		next_action = alarmed_action_queue[0]
	current_action = next_action
	current_action.begin(unit)


func finish_action():
	if current_action == current_action_queue[0]:
		current_action_queue.pop_front()
		clear_action()


func clear_action():
	current_action = null


## Adds an Action to the unit's queue (at the current awareness level). If priority is 0, the unit will add it to the front of the queue and drop whatever they were doing. If a higher integer is passed, it will be added at that position. if it is omitted entirely, the Action will be added to the back of the queue.
func add_action(action : Action, priority : int = current_action_queue.size()) -> void:
	current_action_queue.insert(priority, action)
	if priority == 0:
		clear_action()


## Main function for determining what Action to take while in combat with the player.
func _decide_alarmed_action():
	if !World.level.enemy_awareness.alarm_active:
		var dice_roll = randf()
		DebugConsole.log(dice_roll)
		if dice_roll <= unit.alarm_run_chance:
			add_action(RunForAlarmAction.new())
		else:
			add_action(NoAction.new())
