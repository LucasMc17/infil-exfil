## The root of all match UI, curently split between turn UI and skill usage UI.
@icon("uid://bta26uu8iwr8c")
class_name MatchUI
extends Control

# Turn UI
@onready var _turn_ui : Control = %TurnUi
@onready var _active_unit_options : HBoxContainer = %ActiveUnitOptions

# Skill Usage UI
@onready var _skill_ui : Control = %SkillUi
@onready var _armed_skill_ui : ArmedSkillUI = %ArmedSkillUI

func _ready() -> void:
	Events.skill_use_began.connect(_on_skill_use_began)
	Events.skill_use_ended.connect(_on_skill_use_ended)
	Events.refresh_surfaced_skill_variables.connect(_on_surfaced_variables_refreshed)


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


# NOTE: Something funky going on here. Turn ui persists after skill begun.
func _on_skill_use_began(skill : Skill) -> void:
	if skill.user is FriendlyUnit:
		_turn_ui.visible = true
		_skill_ui.visible = false
		_armed_skill_ui.teardown()

		_active_unit_options.refresh_affordability()


func _on_skill_use_ended(skill : Skill) -> void:
	if skill.user is FriendlyUnit:
		_active_unit_options.refresh_affordability()


func _on_surfaced_variables_refreshed() -> void:
	_armed_skill_ui.build_surfaced_variables()
