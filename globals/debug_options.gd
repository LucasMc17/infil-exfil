## Suite of debug options for easier testing.
extends Node

enum AmmoMode {
	## Normal, limited ammo.
	NORMAL,
	## Normal magazine size, but unlimited ammunition on backup for each unit.
	UNLIMITED_AMMO,
	## Unlimited ammunition, unlimited magazine size.
	BOTTOMLESS_MAG
}

@export_group("God Mode")
## Sets the ammo to normal, unlimited, or bottomless magazine.
@export var ammo_mode := AmmoMode.NORMAL
## When set to true, units have unlimited movement points.
@export var unlimited_mp := false
## When set to true, units have unlimited action points.
@export var unlimited_ap := false

@export_group("Convenience")
## Adjusts the game time scale for faster debugging.
@export var time_scale := 1.0:
	set(val):
		time_scale = val
		Engine.time_scale = val