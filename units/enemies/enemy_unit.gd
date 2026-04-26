@tool
class_name EnemyUnit
extends Unit

@export var unaware_move_distance := 3
@export var alerted_move_distance := 5
@export var alarmed_move_distance := 5

@export var unaware_base_actions : Array[Action] = []
@export var alerted_base_actions : Array[Action] = []

var unaware_action_queue : Array[Action] = []
var alerted_action_queue : Array[Action] = []
var alarmed_action_queue : Array[Action] = []

var current_action : Action

var awareness := EnemyUnitAwarenessModule.new(self)

@onready var vision_zone : VisionZone = %VisionZone

func _ready():
	super()
	debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
	debug_label.change_param('targets', '[]')
	# Events.enemy_action_finished.connect(_on_enemy_action_finished)
	unaware_action_queue = unaware_base_actions.duplicate()


func take_action_from_queue():
	var next_action : Action
	if awareness.awareness_level == awareness.AwarenessLevel.UNAWARE:
		if unaware_action_queue.is_empty():
			unaware_action_queue = unaware_base_actions.duplicate()
		next_action = unaware_action_queue.pop_front()
	elif awareness.awareness_level == awareness.AwarenessLevel.ALERTED:
		next_action = alerted_action_queue.pop_front()
	elif awareness.awareness_level == awareness.AwarenessLevel.ALARMED:
		next_action = alarmed_action_queue.pop_front()
	current_action = next_action
	current_action.begin(self)


func check_for_detection() -> void:
	vision_zone.queue_vision_test()


# func _on_enemy_action_finished(enemy : EnemyUnit):
# 	if enemy == self:
# 		current_action = null


func _on_vision_zone_friendly_seen(friendly: FriendlyUnit) -> void:
	DebugConsole.log("I SEE YA")
	awareness.alarm([friendly])
