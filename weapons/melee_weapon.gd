## A weapon specifically for melee, having a short range and no ammunition.
class_name MeleeWeapon
extends Weapon

@export_group("Utility")
## The range of the weapon.
@export var effective_range := 1.0

@export_group("Noise")
## The noise it makes to use this weapon.
@export var sound_radius := 5.0