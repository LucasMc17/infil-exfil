class_name EnemySightingInspector
extends UnitSightingInspector


@onready var _directive : Label = %Directive

static func new_inspector(sighting : UnitKnowledgeModule.Sighting) -> UnitSightingInspector:
	if sighting is EnemyKnowledgeModule.EnemySighting:
		var inspector = load("uid://0hj8cbjqfhe5").instantiate()
		inspector.sighting = sighting
		return inspector
	return null


func _ready() -> void:
	if sighting:
		super()
		if sighting.last_directive:
			_directive.text = sighting.last_directive.get_script().get_global_name()
		else:
			_directive.text = "Unknown"