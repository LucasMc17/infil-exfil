class_name ArmedSkillUI
extends VBoxContainer

var skill_res : Skill
var selected_target : int = -1

@onready var _name_label : Label = %NameLabel
@onready var _description_label : Label = %DescriptionLabel
@onready var _confirm_button : Button = %ConfirmButton
@onready var _targets_section : TargetsSection = %TargetsSection


func build(skill : Skill) -> void:
	skill_res = skill
	_name_label.text = skill.name
	_description_label.text = skill.description
	_confirm_button.disabled = !skill.get_usability()
	if skill is SingleTargetSkill:
		_targets_section.build(skill)
	_targets_section.visible = skill is SingleTargetSkill


func teardown() -> void:
	skill_res = null
	_name_label.text = ''
	_description_label.text = ''
	_targets_section.teardown()


func _on_cancel_button_pressed() -> void:
	Events.skill_disarmed.emit()


func _on_confirm_button_pressed() -> void:
	skill_res.use()
