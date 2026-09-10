class_name DebugUnitOption
extends Button

signal unit_chosen(unit_option : DebugUnitOption)

var unit : EnemyUnit


static func new_button(u : EnemyUnit) -> DebugUnitOption:
	var scene : DebugUnitOption = load("uid://dsvrhg8gk4lk").instantiate()
	scene.unit = u
	return scene


func _pressed() -> void:
	unit_chosen.emit(self)