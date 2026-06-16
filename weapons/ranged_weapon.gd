class_name RangedWeapon
extends Weapon

@export_group("Ammunition")
@export var capacity := 10
@export var is_magazine_fed := true
@export var maximum_reserve_ammo := 30

@export_group("Noise")
@export var is_silenced := true
@export var sound_radius := 5.0

var current_ammunition : int
var current_reserve_ammo : int

func _init() -> void:
	DebugConsole.log('initializing ranged weapon')
	current_ammunition = capacity
	current_reserve_ammo = maximum_reserve_ammo


func reload(should_discard_unused : bool) -> void:
	var missing_ammo = capacity if should_discard_unused else capacity - current_ammunition
	var to_load = min(missing_ammo, current_reserve_ammo)
	current_reserve_ammo -= to_load
	capacity += to_load
