class_name InvestigateSound
extends Directive

var sound_position : Vector3i

func _init(p : Vector3i) -> void:
	sound_position = p
	_listening = false


func begin(unit : EnemyUnit) -> void:
	super(unit)
	unit.move('Walk', sound_position)


func _on_finished_moving(unit : EnemyUnit, arrived : bool):
	super(unit, arrived)
	if arrived:
		end()
	unit.forfeit_turn()