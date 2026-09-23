class_name StatusInspector
extends PanelContainer

@onready var _acting_state : DebugKVPair = %ActingState
@onready var _position : DebugKVPair = %Position

var unit : EnemyUnit

func refresh(new_unit : EnemyUnit = null) -> void:
	if new_unit:
		unit = new_unit
	if unit:
		_acting_state.value = Unit.Status.find_key(unit.unit_status)
		_position.value = str(unit.board_position)


func _on_kill_button_pressed() -> void:
	if unit:
		unit.die()


func _on_ko_button_pressed() -> void:
	if unit:
		unit.lose_consciousness()


func _on_revive_button_pressed() -> void:
	if unit:
		unit.regain_consciousness()
