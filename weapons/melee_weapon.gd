## A weapon specifically for melee, having a short range and no ammunition.
class_name MeleeWeapon
extends Weapon

@export_group("Utility")
## The range of the weapon.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var effective_range := 1.0