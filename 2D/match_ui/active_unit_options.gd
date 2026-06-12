extends HBoxContainer

const SKILL_SCENE = preload('./unit_skill.tscn')

func _ready() -> void:
	Events.unit_activated.connect(_on_unit_activated)


func _on_unit_activated(unit : Unit) -> void:
	visible = unit is FriendlyUnit
	var weapon = unit.primary_weapon
	if weapon:
		for child in get_children():
			child.queue_free()
		for skill in weapon.skills:
			var skill_button = SKILL_SCENE.instantiate()
			skill_button.build(skill)
			add_child(skill_button)