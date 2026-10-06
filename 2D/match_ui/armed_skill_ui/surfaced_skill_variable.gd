class_name SurfacedSkillVariable
extends VBoxContainer

## The text of the description of this surfaced variables.
var label_text : String
## The text of the surfaced variable.
var value_text : String

@onready var label : Label = %Label
@onready var value : Label = %Value

## Static factory function to create a new UI scene.
static func new_variable(desc : String, variable : Variant) -> SurfacedSkillVariable:
	var scene : SurfacedSkillVariable = load("uid://dtdychgol3wgp").instantiate()
	scene.label_text = desc
	if variable is String:
		scene.value_text = variable
	else:
		scene.value_text = str(variable)
	return scene


func _ready() -> void:
	label.text = label_text
	value.text = value_text