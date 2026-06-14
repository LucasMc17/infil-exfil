extends Control

@onready var _turn_ui : Control = %TurnUi
@onready var _player_turn_options : HBoxContainer = %PlayerTurnOptions
@onready var _active_unit_options : HBoxContainer = %ActiveUnitOptions

@onready var _skill_ui : Control = %SkillUi
@onready var _skill_description : SkillDescription = %SkillDescription

func _ready() -> void:
	Events.skill_armed.connect(_on_skill_armed)
	Events.skill_disarmed.connect(_on_skill_disarmed)


func _on_skill_armed(skill : Skill) -> void:
	_turn_ui.visible = false
	_skill_ui.visible = true
	_skill_description.build(skill)


func _on_skill_disarmed() -> void:
	_turn_ui.visible = true
	_skill_ui.visible = false
	_skill_description.teardown()

	_active_unit_options.refresh_affordability()
