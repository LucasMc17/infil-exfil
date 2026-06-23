class_name TargetIcon
extends TextureButton

signal target_selected(target_icon : TargetIcon)

var target : Unit

func _pressed() -> void:
	target_selected.emit(self)