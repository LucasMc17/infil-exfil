extends TextureButton

var skill_res : Skill

@onready var _label : Label = %Label

func build(skill : Skill, index : int) -> void:
	if index < 10:
		shortcut = Shortcut.new()
		var key_event := InputEventKey.new()
		key_event.keycode = 48 + index as Key
		shortcut.events.append(key_event)
	skill_res = skill


func _ready() -> void:
	if skill_res:
		_label.text = skill_res.name
		refresh_affordability()


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
