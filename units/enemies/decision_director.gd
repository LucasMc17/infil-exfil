class_name DecisionDirector
extends Resource

var unit : EnemyUnit

var awareness : EnemyUnitAwarenessModule

var current_directive : Directive

var unaware_base_directives : Array[Directive]
var alerted_base_directives : Array[Directive]

var unaware_directive_queue : Array[Directive] = []
var alerted_directive_queue : Array[Directive] = []
var alarmed_directive_queue : Array[Directive] = []

var current_directive_queue : Array[Directive]:
	get():
		if awareness.is_unaware():
			return unaware_directive_queue
		if awareness.is_alerted():
			return alerted_directive_queue
		return alarmed_directive_queue

func _init(u : EnemyUnit, a : EnemyUnitAwarenessModule) -> void:
	unit = u
	awareness = a

	unaware_base_directives = unit.unaware_base_directives
	alerted_base_directives = unit.alerted_base_directives


func take_directive_from_queue():
	var next_directive : Directive
	if awareness.is_unaware():
		if unaware_directive_queue.is_empty():
			unaware_directive_queue = unaware_base_directives.duplicate()
		next_directive = unaware_directive_queue[0]
	elif awareness.is_alerted():
		if alerted_directive_queue.is_empty():
			alerted_directive_queue = alerted_directive_queue.duplicate()
		next_directive = alerted_directive_queue[0]
	elif awareness.is_alarmed():
		if alarmed_directive_queue.is_empty():
			_decide_alarmed_directive()
		next_directive = alarmed_directive_queue[0]
	current_directive = next_directive
	current_directive.begin(unit)


func finish_directive():
	if current_directive == current_directive_queue[0]:
		current_directive_queue.pop_front()
		clear_directive()


func clear_directive():
	if current_directive:
		current_directive.cancel()
	current_directive = null


## Adds a Directive to the unit's queue (at the current awareness level). If priority is 0, the unit will add it to the front of the queue and drop whatever they were doing. If a higher integer is passed, it will be added at that position. if it is omitted entirely, the Directive will be added to the back of the queue.
func add_directive(directive : Directive, priority : int = current_directive_queue.size()) -> void:
	current_directive_queue.insert(priority, directive)
	if priority == 0:
		clear_directive()


## Main function for determining what Directive to take while in combat with the player.
func _decide_alarmed_directive():
	if !World.level.enemy_awareness.alarm_active:
		var dice_roll = randf()
		if dice_roll <= unit.alarm_run_chance:
			add_directive(RunForAlarm.new())
		else:
			add_directive(NoDirective.new())
