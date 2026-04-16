@tool
class_name EnemyUnit
extends Unit

enum AwarenessLevel {
	UNAWARE,
	ALERTED,
	ALARMED
}

@export var awareness_level := AwarenessLevel.UNAWARE

@export var unaware_move_distance := 3
@export var alerted_move_distance := 5
@export var alarmed_move_distance := 5

@export var unaware_base_actions : Array[Action] = []
@export var alerted_base_actions : Array[Action] = []

var unaware_action_queue : Array[Action] = []
var alerted_action_queue : Array[Action] = []
var alarmed_action_queue : Array[Action] = []

@onready var state_machine : StateMachine = %StateMachine

@onready var vision_zone : VisionZone = %VisionZone

func _ready():
	unaware_action_queue = unaware_base_actions.duplicate()
	var next_action : Action = unaware_action_queue.pop_front()
	next_action.begin(self)