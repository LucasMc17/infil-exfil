class_name RangedWeapon
extends Weapon

@export_group("Ammunition")
@export var capacity := 10
@export var is_magazine_fed := true
@export var maximum_reserve_ammo := 30

@export_group("Noise")
@export var is_silenced := true
@export var sound_radius := 5.0

var current_ammunition : int:
	set(val):
		current_ammunition = val
		if wielder and wielder.flag:
			wielder.flag.refresh(wielder)
var current_reserve_ammo : int:
	set(val):
		current_reserve_ammo = val
		if wielder and wielder.flag:
			wielder.flag.refresh(wielder)

func initialize(unit : Unit) -> void:
	super(unit)
	current_ammunition = capacity
	current_reserve_ammo = maximum_reserve_ammo

 
func reload(should_discard_unused : bool) -> void:
	if should_discard_unused:
		current_ammunition = min(capacity, current_reserve_ammo)
		current_reserve_ammo = max(current_reserve_ammo - capacity, 0)
	else:
		var missing_ammo = capacity - current_ammunition
		var to_load = min(missing_ammo, current_reserve_ammo)
		current_reserve_ammo -= to_load
		current_ammunition += to_load
