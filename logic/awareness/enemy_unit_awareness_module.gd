class_name EnemyUnitAwarenessModule
extends Resource

signal awareness_changed(old_awareness : AwarenessLevel, new_awareness : AwarenessLevel)

enum AwarenessLevel {
	UNAWARE,
	ALERTED,
	ALARMED
}

var awareness_level := AwarenessLevel.UNAWARE:
	set(val):
		awareness_changed.emit(awareness_level, val)
		awareness_level = val
		unit.debug_label.change_param('awareness_level', AwarenessLevel.find_key(val))

var unit : EnemyUnit

var targeted_friendlies : Array[FriendlyUnit] = []

var targeted_friendly_count : int:
	get():
		return targeted_friendlies.size()

func _init(u : EnemyUnit) -> void:
	unit = u


func alert():
	awareness_level = AwarenessLevel.ALERTED
	targeted_friendlies = []
	unit.debug_label.change_param('targets', '[]')


func alarm(spotted_friendlies : Array[FriendlyUnit] = []):
	if !is_alarmed():
		awareness_level = AwarenessLevel.ALARMED
		unit.movement_machine.current_state.transition('NoMovement')
		unit.forfeit_turn()
	for friendly : FriendlyUnit in spotted_friendlies:
		if !targeted_friendlies.has(friendly):
			targeted_friendlies.append(friendly)
	unit.debug_label.change_param('targets', '[' + ', '.join(targeted_friendlies.map(func (friendly): return friendly.name)) + ']')


func drop_guard():
	awareness_level = AwarenessLevel.UNAWARE
	targeted_friendlies = []
	unit.debug_label.change_param('targets', '[]')


func is_alarmed() -> bool:
	return awareness_level == AwarenessLevel.ALARMED


func is_alerted() -> bool:
	return awareness_level == AwarenessLevel.ALERTED


func is_unaware() -> bool:
	return awareness_level == AwarenessLevel.UNAWARE