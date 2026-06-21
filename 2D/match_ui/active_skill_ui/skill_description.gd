class_name SkillDescription
extends VBoxContainer

var skill_res : Skill

@onready var _name_label : Label = %NameLabel
@onready var _description_label : Label = %DescriptionLabel
@onready var _confirm_button : Button = %ConfirmButton


func build(skill : Skill) -> void:
	skill_res = skill
	_name_label.text = skill.name
	_description_label.text = skill.description
	_confirm_button.disabled = !skill.get_usability()



func teardown() -> void:
	skill_res = null
	_name_label.text = ''
	_description_label.text = ''


func _on_cancel_button_pressed() -> void:
	Events.skill_disarmed.emit()


func _on_confirm_button_pressed() -> void:
	skill_res.use()
