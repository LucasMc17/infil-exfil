class_name UnitFlagContent
extends Control

@onready var _ammo_monitor : PanelContainer = %AmmoMonitor
@onready var _name : Label = %NameLabel
@onready var _mp : Label = %MP
@onready var _ap : Label = %AP
@onready var _current_ammo : Label = %CurrentAmmo
@onready var _backup_ammo : Label = %BackupAmmo

func handle_expand() -> void:
	_ammo_monitor.visible = true


func handle_collapse() -> void:
	_ammo_monitor.visible = false

func handle_refresh(unit) -> void:
	_name.text = unit.name
	_mp.text = str(unit.movement_points)
	_ap.text = str(unit.action_points)
	_current_ammo.text = str(unit.primary_weapon.current_ammunition) if unit.primary_weapon and unit.primary_weapon is RangedWeapon else "0"
	_backup_ammo.text = str(unit.primary_weapon.current_reserve_ammo) if unit.primary_weapon and unit.primary_weapon is RangedWeapon else "0"