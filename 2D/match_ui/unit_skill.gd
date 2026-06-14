extends TextureButton

var skill_res : Skill

@onready var _label : Label = %Label

func build(skill : Skill) -> void:
	skill_res = skill


func _ready() -> void:
	if skill_res:
		_label.text = skill_res.name


func _on_pressed() -> void:
	skill_res.arm(World.level.active_unit)
