class_name BodySightingInspector
extends UnitSightingInspector

@onready var _status : Label = %Status

static func new_inspector(sighting : UnitKnowledgeModule.Sighting) -> UnitSightingInspector:
	if sighting is EnemyKnowledgeModule.BodySighting:
		var inspector = load("uid://cabr4srxa5sbu").instantiate()
		inspector.sighting = sighting
		return inspector
	return null


func _ready() -> void:
	if sighting:
		super()
		if sighting.last_known_status:
			_status.text = Unit.Status.find_key(sighting.last_known_status)
		else:
			_status.text = "Unknown"