extends Node

enum AmmoMode {
	NORMAL,
	UNLIMITED_AMMO,
	BOTTOMLESS_MAG
}

@export_group("God Mode")
@export var ammo_mode := AmmoMode.NORMAL
@export var unlimited_mp := false
@export var unlimited_ap := false