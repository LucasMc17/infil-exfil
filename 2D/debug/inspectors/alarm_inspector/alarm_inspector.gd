extends FoldableContainer

@onready var _status_inspector : AlarmStatusInspector = %AlarmStatusInspector

func _ready() -> void:
	Events.update_alarm_monitor.connect(refresh)


func refresh() -> void:
	_status_inspector.refresh()