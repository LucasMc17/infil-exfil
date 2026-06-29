## A button representing a potential target for skill usage in the UI. Must be called with the [build] function before being added to scene, to ensure the button represents a valid target.
class_name TargetIcon
extends TextureButton

## Emitted when the button is pressed, selecting the [target] unit as the current target in the [SkillTargetingModule].
signal target_selected(target_icon : TargetIcon)

## The unit which this icon represents as a possible target.
var target : Unit

func _pressed() -> void:
	target_selected.emit(self)


## Initialize the button with a target and set a number key short cut based on the index of the button. Must be called before adding to scene.
func build(target_unit : Unit, index: int) -> void:
	target = target_unit
	if index < 10:
		shortcut = Shortcut.new()
		var key_event := InputEventKey.new()
		key_event.keycode = 48 + index as Key
		shortcut.events.append(key_event)