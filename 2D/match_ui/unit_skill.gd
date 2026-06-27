## Texture Button representing a possible skill for arming by the active unit. Must be initialized with the [build] function before being added to the scene.
class_name UnitSkill
extends TextureButton

## The skill this button represents.
var skill_res : Skill

@onready var _label : Label = %Label

func _ready() -> void:
	if skill_res:
		_label.text = skill_res.name
		refresh_affordability()


## Initialize the button with a skill, and create a number key shortcut for arming the skill.
func build(skill : Skill, index : int) -> void:
	if index < 10:
		shortcut = Shortcut.new()
		var key_event := InputEventKey.new()
		key_event.keycode = 48 + index as Key
		shortcut.events.append(key_event)
	skill_res = skill


## Check if the active unit can afford to use the skill via the skill's own [get_affordability] method. Disabled the button if the unit cannot afford the skill.
func refresh_affordability() -> void:
	var affordable = skill_res.get_affordability()
	if !affordable:	
		disabled = true
		# NOTE: This is temporary
		modulate.a = 0.5
	else:
		disabled = false
		modulate.a = 1.0


func _on_pressed() -> void:
	Events.skill_armed.emit(skill_res)
