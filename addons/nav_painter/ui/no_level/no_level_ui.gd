@tool
## The Ui to display when no level is currently loaded in the editor.
class_name NoLevelUI
extends VBoxContainer

## Signal emitted when the refresh button is clicked.
signal refresh_requested()

@onready var _refresh_button : Button = %RefreshButton

func _ready() -> void:
	_refresh_button.pressed.connect(func(): refresh_requested.emit())


## Activate the UI slice, making it visible.
func activate() -> void:
	visible = true


## Shutdown the UI slice, making it invisible.
func deactivate() -> void:
	visible = false
