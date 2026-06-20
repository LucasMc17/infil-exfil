@tool
class_name EnemyUnit
extends Unit

@export var unaware_move_distance := 3
@export var alerted_move_distance := 5
@export var alarmed_move_distance := 5

@export var unaware_base_directives : Array[Directive] = []
@export var alerted_base_directives : Array[Directive] = []

## How likely the unit is to run for the alarm each turn when encoutering the player's units.
@export var alarm_run_chance := 0.5

var awareness := EnemyUnitAwarenessModule.new(self)

var decision_director : DecisionDirector

@onready var seeing_zone : SeeingZone = %SeeingZone

func _ready():
	super()
	awareness.awareness_changed.connect(_on_awareness_changed)
	decision_director = DecisionDirector.new(self, awareness)
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