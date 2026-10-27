class_name InvestigateSound
extends Directive

var sound_position : Vector3i

func _init(p : Vector3i) -> void:
	sound_position = p
	_listening = false


func begin(unit : EnemyUnit) -> void:
	super(unit)
	unit.move('Walk' if !unit.awareness.is_alarmed() else 'Run', sound_position)


func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	if arrived or !unit.awareness.friendlies_in_sight.is_empty():
		end()
	unit.forfeit_turn()