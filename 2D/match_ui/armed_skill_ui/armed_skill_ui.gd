## The slice of game UI related targeting, using or canceling an armed unit skill. Must be initiated with the [build] function before being shown to the user. 
class_name ArmedSkillUI
extends VBoxContainer

## The skill currently represented in the UI.
var skill_res : Skill

@onready var _name_label : Label = %NameLabel
@onready var _description_label : Label = %DescriptionLabel
@onready var _confirm_button : Button = %ConfirmButton
@onready var _targets_section : TargetsSection = %TargetsSection
@onready var _surfaced_variables_holder : HBoxContainer = %SurfacedVariables

func _ready() -> void:
	Events.recheck_skill_usability.connect(_on_recheck_skill_usability)


## Initiate the Armed Skill UI with a selected skill.
func build(skill : Skill) -> void:
	skill_res = skill
	_name_label.text = skill.name
	_description_label.text = skill.description
	_confirm_button.disabled = !skill.get_usability()
	if skill is TargetedSkill:
		_targets_section.build(skill)
	_targets_section.visible = skill is TargetedSkill

	build_surfaced_variables()


## Create and populate the surfaced variables of the currently armed skill in the armed skill UI.
func build_surfaced_variables() -> void:
	Utilities.clear_children(_surfaced_variables_holder)
	for key in skill_res.surfaced_variables.keys():
		var variable_name = skill_res.surfaced_variables[key]
		if variable_name in skill_res:
			var value = skill_res[variable_name]
			var scene = SurfacedSkillVariable.new_variable(key, value)
			_surfaced_variables_holder.add_child(scene)
		else:
			DebugConsole.error('Skill does not have variable named ' + key)


## Remove the UI from the screen and unset the current skill.
func teardown() -> void:
	skill_res = null
	_name_label.text = ''
	_description_label.text = ''
	_targets_section.teardown()
	Utilities.clear_children(_surfaced_variables_holder)


func _on_cancel_button_pressed() -> void:
	if Level.current_level.allow_inputs:
		Events.skill_disarmed.emit()


func _on_confirm_button_pressed() -> void:
	if Level.current_level.allow_inputs:
		skill_res.use()
		Events.skill_disarmed.emit()


func _on_recheck_skill_usability() -> void:
	_confirm_button.disabled = !skill_res.get_usability()
