class_name UnitInspector
extends HBoxContainer

@onready var _option_list : VBoxContainer = %OptionList


func _ready() -> void:
	Events.level_loaded.connect(_make_all_option_buttons)


func make_option_button(unit : EnemyUnit) -> void:
	var button = DebugUnitOption.new_button(unit)
	_option_list.add_child(button)
	button.unit_chosen.connect(_on_option_chosen)


func _make_all_option_buttons() -> void:
	for unit : EnemyUnit in Level.current_level.all_enemies:
		make_option_button(unit)


func _on_option_chosen(option : DebugUnitOption) -> void:
	for child : DebugUnitOption in _option_list.get_children():
		child.button_pressed = child == option