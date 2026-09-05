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
@export_range(0.0, 1.0, 0.01, "suffix:%") var alarm_run_chance := 0.5

## The enemy unit's awareness module.
var awareness := EnemyUnitAwarenessModule.new(self)
## The enemy unit's decision director.
var decision_director : DecisionDirectorModule
## Dictionary of skills usable by this enemy unit by name.
var available_skills : Dictionary[String, Skill] = {}

# Temporary vars to be reset at the end of next turn
## The unit which this unit was last blocked by when attempting to path to a specific point with no favorable alternate path.
var temp_blocker : Unit
## The path of another unit which this unit has just blocked. Used to help find a new position to move to where desirable actions can be performed but the path is unblocked.
var temp_blocking_path : PackedVector3Array = []

@onready var seeing_zone : SeeingZone = %SeeingZone
@onready var _status_indicator : Sprite3D = %StatusIndicator
@onready var suppression_indicator : SuppressionIndicator = %SuppressionIndicator

func _ready():
	super()
	if !Engine.is_editor_hint():
		for child in skill_machine.get_children():
			available_skills[child.name] = child
		awareness.awareness_changed.connect(_on_awareness_changed)
		decision_director = DecisionDirectorModule.new(self, awareness)
		debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
		debug_label.change_param('targets', '[]')
		Events.alarm_raised.connect(_on_alarm_raised)
		Events.unit_disabled.connect(_on_unit_disabled)


func check_for_detection() -> void:
	DebugConsole.log("Checking for detection", 2)
	# awareness.confirm_all_sightings()
	return seeing_zone.check_detection()


func _on_unit_disabled(unit : Unit) -> void:
	if unit == self or unit == awareness.suppression_target:
		awareness.lose_suppression()


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


func damage(amount : int) -> void:
	super(amount)
	awareness.lose_suppression()


func die() -> void:
	super()
	update_indicator()


func regain_consciousness() -> void:
	super()
	awareness.alert()
	update_indicator()


func forfeit_turn() -> void:
	temp_blocker = null
	temp_blocking_path = []
	super()


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