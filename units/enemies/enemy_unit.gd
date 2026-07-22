@tool
## The basic class of enemy in the game. Initializes own logic around decision making and player awareness tracking and acts autonomously during gameplay.
class_name EnemyUnit
extends Unit

const STUN_IMAGE := preload('res://assets/images/stun.png')
const SLEEP_IMAGE := preload('res://assets/images/sleep.png')
const INVESTIGATING_IMAGE := preload('res://assets/images/investigating.png')
const HALF_ALERT_IMAGE := preload('res://assets/images/half_alert.png')
const FULL_ALERT_IMAGE := preload('res://assets/images/full_alert.png')

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
@onready var _status_indicator : Sprite3D = %StatusIndicator

func _ready():
	super()
	awareness.awareness_changed.connect(_on_awareness_changed)
	decision_director = DecisionDirectorModule.new(self, awareness)
	debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
	debug_label.change_param('targets', '[]')
	Events.alarm_raised.connect(_on_alarm_raised)


func check_for_detection() -> void:
	DebugConsole.log("Checking for detection", 2)
	awareness.confirm_all_sightings()
	return seeing_zone.check_detection()


func _on_seeing_zone_friendly_seen(friendlies: Array[FriendlyUnit]) -> void:
	DebugConsole.log("Enemy Sees Friendly/Friendlies", 2)
	awareness.alarm(friendlies, true)


func _on_awareness_changed(_old_awareness, _new_awareness):
	decision_director.clear_directive()
	update_indicator()


func _on_alarm_raised(_alarm, _raiser) -> void:
	awareness.alarm([], false)


func activate():
	super()
	awareness.resolve_grace_period()
	update_indicator()


func lose_consciousness() -> void:
	super()
	update_indicator()


func die() -> void:
	super()
	update_indicator()


func regain_consciousness() -> void:
	super()
	update_indicator()


## Update the enemy's icon status indicator.
func update_indicator() -> void:
	if unit_status == Status.DEAD:
		_status_indicator.texture = null
	elif unit_status == Status.UNCONSCIOUS:
		_status_indicator.texture = SLEEP_IMAGE
	elif unit_status == Status.STUNNED:
		_status_indicator.texture = STUN_IMAGE
	elif awareness.is_alarmed():
		if awareness.is_in_grace_period:
			_status_indicator.texture = HALF_ALERT_IMAGE
		else:
			_status_indicator.texture = FULL_ALERT_IMAGE
	else:
		_status_indicator.texture = null