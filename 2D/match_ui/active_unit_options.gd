extends HBoxContainer

const SKILL_SCENE = preload('./unit_skill.tscn')

func _ready() -> void:
	Events.unit_activated.connect(_on_unit_activated)


func refresh_affordability() -> void:
	for child in get_children():
		child.refresh_affordability()


func _on_unit_activated(unit : Unit) -> void:
	for child in get_children():
		child.queue_free()
	var index := 1
	for skill in unit.all_skills:
		var skill_button = SKILL_SCENE.instantiate()
		skill_button.build(skill, index)
		add_child(skill_button)
		index += 1