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
	## How many turns have passed since this unit was last in sight.
	var turns_since_sighted := 0

	func _init(seen_unit : Unit) -> void:
		Events.enemy_turn_ended.connect(_on_turn_ended)
		super(seen_unit)
		still_in_sight = false
		seen_unit.decision_director.directive_changed.connect(_on_enemy_changed_directive)
	

	func _on_enemy_changed_directive(directive : Directive) -> void:
		if still_in_sight and directive:
			last_directive = directive
	

	func _on_turn_ended() -> void:
		if !still_in_sight:
			turns_since_sighted += 1
			Events.request_update_unit_monitor.emit(unit)


func _init(a : EnemyUnitAwarenessModule) -> void:
	super(a)
	SightingObject = EnemySighting
	Events.level_loaded.connect(_setup_knowledge)


## Utility func to create initial awareness of fellow enemy units.
func _setup_knowledge() -> void:
	for enemy : EnemyUnit in Level.current.all_enemies:
		if enemy != unit:
			add_sighting(enemy)

	confirm_all_sightings()


## Returns true if the unit is aware of another unit running for the alarm that they have been in sight of within the last 5 turns.
func is_aware_of_alarm_runner() -> bool:
	var aware = sightings.values().any(func (sighting : EnemySighting):
		return sighting.last_directive is RunForAlarm and sighting.turns_since_sighted < 5)
	return aware


func _on_sighting_confirmed(_sighting : Sighting, enemy_sighting : EnemySighting = null) -> void:
	if enemy_sighting.enemy.decision_director.current_directive:
		enemy_sighting.last_directive = enemy_sighting.enemy.decision_director.current_directive
	enemy_sighting.turns_since_sighted = 0
