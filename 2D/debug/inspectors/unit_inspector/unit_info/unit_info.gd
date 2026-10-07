class_name DebugUnitInfo
extends PanelContainer

@onready var _name_label : Label = %Name

@onready var _status_inspector : UnitStatusInspector = %UnitStatusInspector
@onready var _awareness_inspector : UnitAwarenessInspector = %UnitAwarenessInspector
@onready var _bodies_dict_inspector : BodiesDictInspector = %BodiesDictInspector
@onready var _directive_inspector : UnitDirectiveInspector = %UnitDirectiveInspector

var unit : EnemyUnit

func _ready() -> void:
	Events.request_update_unit_monitor.connect(_on_refresh_requested)

func display_unit_info(u : EnemyUnit) -> void:
	if u:
		unit = u
		visible = true
		_name_label.text = unit.name

		_awareness_inspector.refresh(unit.awareness)
		_directive_inspector.refresh(unit.decision_director)
		_status_inspector.refresh(unit)
		_bodies_dict_inspector.refresh(unit.awareness.known_bodies)


func refresh() -> void:
	display_unit_info(unit) 


func _on_refresh_requested(u : EnemyUnit) -> void:
	if u == unit:
		refresh()
		
