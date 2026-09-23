extends FoldableContainer

@onready var _status_inspector : AlarmStatusInspector = %AlarmStatusInspector
@onready var _bodies_inspector : BodiesDictInspector = %BodiesDictInspector

func _ready() -> void:
	Events.update_alarm_monitor.connect(refresh)


func refresh() -> void:
	_status_inspector.refresh()
	_bodies_inspector.refresh(Level.current_level.enemy_awareness.known_bodies)