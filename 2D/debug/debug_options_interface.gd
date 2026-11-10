extends FoldableContainer

@onready var _ammo_mode_select : OptionButton = %AmmoModeSelect
@onready var _unlimited_mp_check : CheckBox = %UnlimitedMPCheck
@onready var _unlimited_ap_check : CheckBox = %UnlimitedAPCheck
@onready var _time_scale_range : SpinBox = %TimeScaleRange

func _ready() -> void:
	_ammo_mode_select.selected = _ammo_mode_select.get_item_id(DebugSettings.CURRENT.ammo_mode)
	_unlimited_mp_check.button_pressed = DebugSettings.CURRENT.unlimited_mp
	_unlimited_ap_check.button_pressed = DebugSettings.CURRENT.unlimited_ap
	_time_scale_range.value = DebugSettings.CURRENT.time_scale

	_ammo_mode_select.item_selected.connect(func (idx : int): _update_debug_setting(DebugSettings.AmmoMode.find_key(idx), "ammo_mode"))
	_unlimited_mp_check.toggled.connect(_update_debug_setting.bind("unlimited_mp"))
	_unlimited_ap_check.toggled.connect(_update_debug_setting.bind("unlimited_ap"))
	_time_scale_range.value_changed.connect(_update_debug_setting.bind("time_scale"))


func _update_debug_setting(setting_value : Variant, setting_name : StringName) -> bool:
	var path = DebugSettings.CURRENT.resource_path
	if setting_name in DebugSettings.CURRENT:
		DebugSettings.CURRENT.set(setting_name, setting_value)
		var error := ResourceSaver.save(DebugSettings.CURRENT, path)
		return error == OK
	DebugConsole.error("Property " + setting_name + "not found in Debug Settings File.")
	return false