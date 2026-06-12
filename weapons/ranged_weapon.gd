class_name RangedWeapon
extends Weapon

@export_group("Ammunition")
@export var capacity := 10
@export var is_magazine_fed := true

@export_group("Noise")
@export var is_silenced := true
@export var sound_radius := 5.0