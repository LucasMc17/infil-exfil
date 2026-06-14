extends TextureButton

var skill_res : Skill

@onready var _label : Label = %Label

func build(skill : Skill) -> void:
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
	World.level.armed_skill = skill_res
	skill_res.arm()
