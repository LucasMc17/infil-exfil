## Module responsible for tracking an [EnemyUnit]'s entire knowledge base about their own team's other units within the level. This includes known enemies in the unit's sight (and their current directives) as well as the locations of any dead or incapacitated units.
class_name EnemyKnowledgeModule
extends UnitKnowledgeModule

class EnemySighting extends Sighting:
	## The sighted enemy unit.
	var enemy : EnemyUnit:
		get():
			return unit
	## The last observed directive this unit was undertaking.
	var last_directive : Directive

	func _init(seen_unit : Unit) -> void:
		super(seen_unit)
		still_in_sight = false
		seen_unit.decision_director.directive_changed.connect(_on_enemy_changed_directive)
	

	func _on_enemy_changed_directive(directive : Directive) -> void:
		if still_in_sight and directive:
			last_directive = directive


func _init(a : EnemyUnitAwarenessModule) -> void:
	super(a)
	SightingObject = EnemySighting
	Events.level_loaded.connect(_setup_knowledge)


func _setup_knowledge() -> void:
	for enemy : EnemyUnit in Level.current.all_enemies:
		add_sighting(enemy)

	confirm_all_sightings()


func _on_sighting_confirmed(_sighting : Sighting, enemy_sighting : EnemySighting = null) -> void:
	enemy_sighting.last_directive = enemy_sighting.enemy.decision_director.current_directive
