class_name EnemyUnitAwarenessModule
extends Resource

enum AwarenessLevel {
	UNAWARE,
	ALERTED,
	ALARMED
}

var awareness_level := AwarenessLevel.UNAWARE:
	set(val):
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
	awareness_level = AwarenessLevel.ALARMED
	for friendly : FriendlyUnit in spotted_friendlies:
		if !targeted_friendlies.has(friendly):
			targeted_friendlies.append(friendly)
	unit.debug_label.change_param('targets', '[' + ', '.join(targeted_friendlies.map(func (friendly): return friendly.name)) + ']')


func drop_guard():
	awareness_level = AwarenessLevel.UNAWARE
	targeted_friendlies = []
	unit.debug_label.change_param('targets', '[]')