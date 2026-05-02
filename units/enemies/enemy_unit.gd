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

@onready var vision_zone : VisionZone = %VisionZone

func _ready():
	super()
	awareness.awareness_changed.connect(_on_awareness_changed)
	decision_director = DecisionDirector.new(self, awareness)
	debug_label.change_param('awareness_level', awareness.AwarenessLevel.find_key(awareness.awareness_level))
	debug_label.change_param('targets', '[]')


func check_for_detection() -> bool:
	return vision_zone.test_visibility()


func _on_vision_zone_friendly_seen(friendlies: Array[FriendlyUnit]) -> void:
	DebugConsole.log("I SEE YA")
	if !awareness.is_alarmed():
		awareness.alarm(friendlies)
		forfeit_turn()


# This needs work.
func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		movement_machine.current_state.transition('NoMovement')
		return
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()
		if !awareness.is_alarmed():
			var alarmed = check_for_detection()
			if alarmed:
				movement_machine.current_state.transition('NoMovement')


func _on_awareness_changed(_old_awareness, _new_awareness):
	decision_director.clear_directive()
