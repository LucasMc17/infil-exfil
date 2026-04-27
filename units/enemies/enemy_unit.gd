@tool
class_name EnemyUnit
extends Unit

@export var unaware_move_distance := 3
@export var alerted_move_distance := 5
@export var alarmed_move_distance := 5

@export var unaware_base_actions : Array[Action] = []
@export var alerted_base_actions : Array[Action] = []

## How likely the unit is to run for the alarm each turn when encoutering the player's units.
@export var alarm_run_chance := 0.5

var awareness := EnemyUnitAwarenessModule.new(self)

var action_director : ActionDirector

@onready var vision_zone : VisionZone = %VisionZone

func _ready():
	super()
	awareness.awareness_changed.connect(_on_awareness_changed)
	action_director = ActionDirector.new(self, awareness)
	debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
	debug_label.change_param('targets', '[]')
	# Events.enemy_action_finished.connect(_on_enemy_action_finished)
	# unaware_action_queue = unaware_base_actions.duplicate()


func check_for_detection() -> bool:
	return vision_zone.test_visibility()


# func _on_enemy_action_finished(enemy : EnemyUnit):
# 	if enemy == self:
# 		current_action = null


func _on_vision_zone_friendly_seen(friendlies: Array[FriendlyUnit]) -> void:
	DebugConsole.log("I SEE YA")
	awareness.alarm(friendlies)


func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		state_machine.current_state.transition('FinishedMoving')
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		var alarmed = check_for_detection()
		if !alarmed:
			path.pop_front()
		else:
			state_machine.current_state.transition('FinishedMoving')


func _on_awareness_changed(_old_awareness, _new_awareness):
	action_director.clear_action()
