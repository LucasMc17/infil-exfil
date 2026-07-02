@tool
## The basic class of enemy in the game. Initializes own logic around decision making and player awareness tracking and acts autonomously during gameplay.
class_name EnemyUnit
extends Unit

## Starting queue of directives to perform when unaware. Passed directly to the [DecisionDirectorModule].
@export var unaware_base_directives : Array[Directive] = []
## Starting queue of directives to perform when alerted. Passed directly to the [DecisionDirectorModule].
@export var alerted_base_directives : Array[Directive] = []

## How likely the unit is to run for the alarm each turn when alarmed by the player's units.
@export var alarm_run_chance := 0.5

## The enemy unit's awareness module.
var awareness := EnemyUnitAwarenessModule.new(self)
## The enemy unit's decision director.
var decision_director : DecisionDirectorModule

@onready var seeing_zone : SeeingZone = %SeeingZone

func _ready():
	super()
	awareness.awareness_changed.connect(_on_awareness_changed)
	decision_director = DecisionDirectorModule.new(self, awareness)
	debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
	debug_label.change_param('targets', '[]')
	Events.alarm_raised.connect(_on_alarm_raised)


func check_for_detection() -> void:
	DebugConsole.log("Checking for detection", 2)
	return seeing_zone.check_detection()


func _on_seeing_zone_friendly_seen(friendlies: Array[FriendlyUnit]) -> void:
	DebugConsole.log("Enemy Sees Friendly/Friendlies", 2)
	awareness.alarm(friendlies)


func _on_awareness_changed(_old_awareness, _new_awareness):
	decision_director.clear_directive()


func _on_alarm_raised(_alarm, _raiser) -> void:
	awareness.alarm([])