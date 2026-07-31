## Class for handling moving in and out of states as units use various skills in their arsenals. A variation on a [state_machine] which allows for a null state to be selected
class_name SkillMachine
extends Node3D

## The owning unit.
@export var unit : Unit

## The currently selected skill. Can be null.
var current_skill : Skill
## The full list of skills available for this skill machine.
var skills : Dictionary[String, Skill] = {}
## The timer to use to determine how long to remain in the current state.
var timer := 1.0

func _ready() -> void:
	for child in get_children():
		if child is Skill:
			skills[child.name] = child
			child.used.connect(_on_skill_used)
		else:
			push_warning("Skill machine contains incompatible child node")
	
	await unit.ready
	unit.debug_label.change_param('current_skill', "No Skill")


func _process(delta: float) -> void:
	if current_skill:
		timer -= delta
		if timer <= 0.0:
			end_skill()


func _on_skill_used(skill : Skill) -> void:
	if !current_skill:
		current_skill = skill
		timer = current_skill.time_to_perform
		unit.debug_label.change_param('current_skill', current_skill.name)
		unit.started_acting.emit(unit)
		current_skill.begin_use()	


func end_skill() -> void:
	if current_skill:
		current_skill.end_use()
	unit.debug_label.change_param('current_skill', "No Skill")
	unit.finished_acting.emit(unit)
	current_skill = null