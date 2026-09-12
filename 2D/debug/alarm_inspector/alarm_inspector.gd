extends FoldableContainer

@onready var _active : DebugKVPair = %Active
@onready var _countdown : DebugKVPair = %TurnsLeft

func _ready() -> void:
	Events.update_alarm_monitor.connect(refresh)


func refresh() -> void:
	_active.value = "TRUE" if Level.current_level.alarm.active else "FALSE"
	_countdown.value = str(Level.current_level.alarm.countdown)