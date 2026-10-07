class_name AlarmStatusInspector
extends PanelContainer

@onready var _active : DebugKVPair = %Active
@onready var _countdown : DebugKVPair = %TurnsLeft

func refresh() -> void:
	_active.value = "TRUE" if Level.current_level.alarm.active else "FALSE"
	_countdown.value = str(Level.current_level.alarm.countdown)