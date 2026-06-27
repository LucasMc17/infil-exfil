## The slice of game UI related targeting, using or canceling an armed unit skill. Must be initiated with the [build] function before being shown to the user. 
class_name ArmedSkillUI
extends VBoxContainer

## The skill currently represented in the UI.
var skill_res : Skill

@onready var _name_label : Label = %NameLabel
@onready var _description_label : Label = %DescriptionLabel
@onready var _confirm_button : Button = %ConfirmButton
@onready var _targets_section : TargetsSection = %TargetsSection


## Initiate the Armed Skill UI with a selected skill.
func build(skill : Skill) -> void:
	skill_res = skill
	_name_label.text = skill.name
	_description_label.text = skill.description
	_confirm_button.disabled = !skill.get_usability()
	if skill is SingleTargetSkill:
		_targets_section.build(skill)
	_targets_section.visible = skill is SingleTargetSkill


## Remove the UI from the screen and unset the current skill.
func teardown() -> void:
	skill_res = null
	_name_label.text = ''
	_description_label.text = ''
	_targets_section.teardown()


func _on_cancel_button_pressed() -> void:
	Events.skill_disarmed.emit()
	Events.target_cleared.emit()


func _on_confirm_button_pressed() -> void:
	skill_res.use()
	Events.target_cleared.emit()
