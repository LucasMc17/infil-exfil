## A ranged weapon, with a longer range and information about its ammunition capacity.
class_name RangedWeapon
extends Weapon

@export_group("Ammunition")
## The amount of ammunition that can be held in the weapon at once in a magazine or chamber (therefore not including backup ammunition which has not been loaded into the weapon)
@export var capacity := 10
## Whether or not this weapon takes a magazine, which informs certain features.
@export var is_magazine_fed := true
## The amount of ammunition that can be stored for this weapon on the user's person, not loaded into the weapon.
@export var maximum_reserve_ammo := 30

@export_group("Noise")
## Whether or not the weapon is silenced, which informs how enemies react to the sound.
@export var is_silenced := true
## From how far away this weapon can be heard when operated.
@export var sound_radius := 5.0

## How much ammunition is currently stored in the weapon itself. Should not exceed the [capacity] variable.
var current_ammunition : int:
	set(val):
		current_ammunition = val
		if wielder and wielder.flag:
			wielder.flag.refresh(wielder)
## How much ammunition is currently stored on backup on the user's person. Should not exceed the [maximum_reserve_ammo] variable.
var current_reserve_ammo : int:
	set(val):
		current_reserve_ammo = val
		if wielder and wielder.flag:
			wielder.flag.refresh(wielder)

func initialize(unit : Unit) -> void:
	super(unit)
	if DebugOptions.ammo_mode as int == 2:
		current_ammunition = int(INF)
	else:
		current_ammunition = capacity
	if DebugOptions.ammo_mode as int > 0:
		current_reserve_ammo = int(INF)
	else:
		current_reserve_ammo = maximum_reserve_ammo


## Reload the weapon, taking ammunition from the reserve. If [should_discard_unused] is true, the reamining ammunition in the weapon magazine will be discarded.
func reload(should_discard_unused : bool) -> void:
	if DebugOptions.ammo_mode as int == 1:
		current_ammunition = capacity
	elif should_discard_unused:
		current_ammunition = min(capacity, current_reserve_ammo)
		current_reserve_ammo = max(current_reserve_ammo - capacity, 0)
	else:
		var missing_ammo = capacity - current_ammunition
		var to_load = min(missing_ammo, current_reserve_ammo)
		current_reserve_ammo -= to_load
		current_ammunition += to_load
