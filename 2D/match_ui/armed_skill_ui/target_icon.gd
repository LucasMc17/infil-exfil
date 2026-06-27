class_name TargetIcon
extends TextureButton

signal target_selected(target_icon : TargetIcon)

var target : Unit

func build(target_unit : Unit, index: int) -> void:
	target = target_unit
	if index < 10:
		shortcut = Shortcut.new()
		var key_event := InputEventKey.new()
		key_event.keycode = 48 + index as Key
		shortcut.events.append(key_event)


func _pressed() -> void:
	target_selected.emit(self)