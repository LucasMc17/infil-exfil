@abstract class_name Weapon
extends Resource

@export_group("Weapon Info")
@export var name := "Weapon Name"
@export_multiline var description := "Weapon description"

@export_group("Weapon Visuals")
@export var model : Mesh

@export_group("Weapon Skills")
@export var skills : Array[Skill]

func make_unique() -> Weapon:
	var result = self.duplicate(true)
	var temp = skills.duplicate()
	skills = []
	for skill in temp:
		skills.append(skill.make_unique())
	return result