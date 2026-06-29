## Resource representing a weapon for use by a unit.
@abstract class_name Weapon
extends Resource

@export_group("Weapon Info")
## The weapon's name.
@export var name := "Weapon Name"
## A description of the weapon.
@export_multiline var description := "Weapon description"

@export_group("Weapon Visuals")
## The weapon's mesh.
@export var model : Mesh

@export_group("Weapon Skills")
## The skills which this weapon allows to be performed when equipped.
@export var skills : Array[Skill]

## The unit who has this weapon equipped.
var wielder : Unit

## Sets up the resource with necessary information.
func initialize(unit : Unit) -> void:
	wielder = unit


## Returns a unique instance of this weapon, including its sub resources.
func make_unique() -> Weapon:
	var result = self.duplicate(true)
	var temp = skills.duplicate()
	skills = []
	for skill in temp:
		skills.append(skill.make_unique())
	return result