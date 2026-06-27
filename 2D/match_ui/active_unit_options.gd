## The UI slice representing the skills available for use by the current active [FriendlyUnit].
class_name ActiveUnitOptions
extends HBoxContainer

## The [UnitSkill] scene for instantiation.
const SKILL_SCENE = preload('./unit_skill.tscn')

func _ready() -> void:
	Events.unit_activated.connect(_on_unit_activated)


## Check the affordability of each available skill for the active unit via their own [refresh_affordability] methods.
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