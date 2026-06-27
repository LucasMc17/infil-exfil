## The root of all match UI, curently split between turn UI and skill usage UI.
class_name MatchUI
extends Control

# Turn UI
@onready var _turn_ui : Control = %TurnUi
@onready var _active_unit_options : HBoxContainer = %ActiveUnitOptions

# Skill Usage UI
@onready var _skill_ui : Control = %SkillUi
@onready var _armed_skill_ui : ArmedSkillUI = %ArmedSkillUI

func _ready() -> void:
	Events.skill_used.connect(_on_skill_used)


## Build the skill UI with the armed skill.
func arm_skill_ui(skill : Skill) -> void:
	_turn_ui.visible = false
	_skill_ui.visible = true
	_armed_skill_ui.build(skill)


## Teardown the skill UI when the active unit disarms its skill.
func disarm_skill_ui() -> void:
	_turn_ui.visible = true
	_skill_ui.visible = false
	_armed_skill_ui.teardown()


func _on_skill_used(_skill : Skill, user : Unit) -> void:
	if user is FriendlyUnit:
		_turn_ui.visible = true
		_skill_ui.visible = false
		_armed_skill_ui.teardown()

		_active_unit_options.refresh_affordability()
