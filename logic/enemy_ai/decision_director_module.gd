## A logic module which makes decisions about which [Directive]s to pursue first, for AI-controlled units.
## [br]Functions by maintaining several queues of [Directive] resources, one for each alertness state of the unit. Cycles through them in order and makes a decision about what directive to pursue next when the last member of the queue is finished. For low alert states, this can be simply to restart the original queue. For high alert states this will be a more complicated decision process based on available information.
class_name DecisionDirectorModule
extends Resource

## The Unit for whom this director is making decisions.
var unit : EnemyUnit
## The awareness module for this director (and the unit)
var awareness : EnemyUnitAwarenessModule
## The currently actioned directive
var current_directive : Directive

## The starting queue of directives to follow when unaware. Will be restarted when ended.
var unaware_base_directives : Array[Directive]
## The starting queue of directives to follow when alerted. Will be restarted when ended.
var alerted_base_directives : Array[Directive]

## The current queue of directives to carry out when unaware.
var unaware_directive_queue : Array[Directive] = []
## The current queue of directives to carry out when alerted.
var alerted_directive_queue : Array[Directive] = []
## The current queue of directives to carry out when alarmed.
var alarmed_directive_queue : Array[Directive] = []

## The current directive queue the unit is working through, depending on their awareness level.
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


## Take the next directive from the appropriate queue and assign it as the current directive. If the current directive queue is empty, it will restart the unaware or alerted queue, where as if the unit is alarmed, it will utilize the [_decide_alarmed_directive] function to determine what action to take next.
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


## Ends the current directive by marking it finished, and then removes it from the directive queue.
func finish_directive():
	if current_directive == current_directive_queue[0]:
		current_directive_queue.pop_front()
		clear_directive()


## Cancels the current directive, if one exists, without marking it complete.
func clear_directive():
	if current_directive:
		current_directive.cancel()
	current_directive = null


## Adds a Directive to the unit's queue (at the current awareness level). If priority is 0, the unit will add it to the front of the queue and drop whatever they were doing. If a higher integer is passed, it will be added at that position. if it is omitted entirely, the Directive will be added to the back of the queue.
func add_directive(directive : Directive, priority : int = current_directive_queue.size()) -> void:
	current_directive_queue.insert(priority, directive)
	if priority == 0:
		clear_directive()


# NOTE: This will likely get pretty big.
## Main function for determining what Directive to take while alarmed, and in combat with the player.
func _decide_alarmed_directive():
	if !World.level.enemy_awareness.alarm_active:
		var dice_roll = randf()
		if dice_roll <= unit.alarm_run_chance:
			add_directive(RunForAlarm.new())
		else:
			add_directive(NoDirective.new())
	else:
		add_directive(NoDirective.new())
