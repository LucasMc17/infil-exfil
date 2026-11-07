## Logic module for handling an individual enemy unit's awareness of the intruding friendlies. This operates in conjunction with the [EnemyTeamAwarenessModule] (which handles team-level awareness) to inform the overall alertness state of the enemy team.
class_name EnemyUnitAwarenessModule
extends Resource

## Signal emitted when the enemy's awareness is changed, either escalating or de-escalating.
signal awareness_changed(old_awareness : AwarenessLevel, new_awareness : AwarenessLevel)

## Signal emitted when the unit confirms a sighting of a [FriendltUnit]. Mirrors the global signal but allows for local context.
signal friendly_spotted(friendly : FriendlyUnit)

# TODO: This friendly sighting system is getting complicated enough to possibly warrant its own file


## The possible awareness states which an enemy unit can operate under.
enum AwarenessLevel {
	## No knowledge whatsoever of friendlies-- no alert.
	UNAWARE,
	## Aware of friendly presence, but not of their general position-- high alert.
	ALERTED,
	## Aware of friendly presence and of their general or specific position-- either in combat or moving towards combat.
	ALARMED
}

## The unit's knowledge base for the player controlled friendly units.
var friendly_knowledge : FriendlyKnowledgeModule
## The unit's knowledge base for the AI controlled enemy units.
var enemy_knowledge : EnemyKnowledgeModule
## The enemy's current awareness level.
var awareness_level := AwarenessLevel.UNAWARE:
	set(val):
		last_awareness_level = awareness_level
		awareness_level = val
		awareness_changed.emit(last_awareness_level, val)
		Events.request_update_unit_monitor.emit(unit)
## Whether or not this enemy has laid eyes on enemy's. At the moment this is almost exclusively used for determining how they should vocally react to contact ('We have intruders' vs. 'Found them'). Despite this description, it also becomes 'true' when the unit hears an alarm go off.
var has_seen_enemies := false
# NOTE: Not in love with this.
## Tracker for the awareness level the unit was in before the current one. For use in certain aspects of resolving the alarm grace period.
var last_awareness_level := AwarenessLevel.UNAWARE
## The unit to whom this awareness module belongs.
var unit : EnemyUnit
## Whether or not the unit will first attempt to detain friendly units when encountering them.
var will_attempt_to_detain := true
## Whether the unit is in the detection grace period. This occurs when the unit sees a friendly unit during the player turn. While in the grace period, stealth skills are still usable on this unit. The grace period ends as soon as the enemy unit begins its next turn.
var is_in_grace_period := false
## A dictionary of bodies which this unit is aware of.
var known_bodies := Utilities.BodiesDict.new(unit)

func _init(u : EnemyUnit) -> void:
	unit = u
	friendly_knowledge = FriendlyKnowledgeModule.new(self)
	enemy_knowledge = EnemyKnowledgeModule.new(self)


## Update the unit's awareness level to [ALERTED].
func alert():
	is_in_grace_period = false
	friendly_knowledge.reset_friendly_knowledge()
	awareness_level = AwarenessLevel.ALERTED
	unit.debug_label.change_param('targets', '[]')
	Events.request_update_unit_monitor.emit(unit)


## Runs when the unit visually acquires a player unit. Triggers an alarm phase and adds them to the targeted friendlies dict as necessary. Separate from the [_confirm_sighting] func which is responsible for confirming whether a previously spotted player unit is still in sight.
func see_friendlies(friendlies : Variant, should_skip_grace_period := false) -> void:
	var first_sighting = friendly_knowledge.has_none_in_sight
	var friendlies_array : Array[FriendlyUnit]
	if friendlies is FriendlyUnit:
		friendlies_array = [friendlies]
	else:
		friendlies_array = friendlies
	friendly_knowledge.handle_seen_friendlies(friendlies_array, should_skip_grace_period)
	if !is_alarmed() or first_sighting:
		unit.stop_moving()
		alarm(should_skip_grace_period)
	has_seen_enemies = true
	Events.request_update_unit_monitor.emit(unit)


## Update the unit's awareness level to [ALARMED], instantly stopping the unit if they are moving, and adding all sighted friendlies to their list of targets.
func alarm(skip_grace_period := false):
	if is_alarmed():
		return
	unit.listening = false
	if !skip_grace_period:
		is_in_grace_period = true
	awareness_level = AwarenessLevel.ALARMED
	if unit.is_active:
		unit.forfeit_turn()


## Update the unit's awareness level to [UNAWARE], clearing their list of targets.
func drop_guard():
	is_in_grace_period = false
	friendly_knowledge.reset_friendly_knowledge()
	awareness_level = AwarenessLevel.UNAWARE
	unit.debug_label.change_param('targets', '[]')
	Events.request_update_unit_monitor.emit(unit)


## Respond to an overheard sound, assuming the user is not in active combat.
func hear_sound(sound : Sound, sound_position : Vector3i) -> void:
	if unit.listening and !unit.is_incapacitated():
		if sound.severity == Sound.Severity.ALARMING or (sound.severity == Sound.Severity.SUSPICIOUS and awareness_level != AwarenessLevel.UNAWARE):
			alarm()
			if !sound.custom_reaction_lines.is_empty():
				unit.speak(sound.custom_reaction_lines.pick_random())
			else:
				unit.speak(Barks.get_alarming_sound_line(sound.description))
		else:
			if !sound.custom_reaction_lines.is_empty():
				unit.speak(sound.custom_reaction_lines.pick_random())
			else:
				unit.speak(Barks.get_normal_sound_line())
		unit.decision_director.clear_queue()
		unit.decision_director.add_directive(InvestigateSound.new(sound_position))


## Reset the grace period bool to false.
func resolve_grace_period():
	if friendly_knowledge.grace_period_alarmer and is_in_grace_period:
		unit.react_to_sighting(friendly_knowledge.grace_period_alarmer.last_known_zone, last_awareness_level == AwarenessLevel.UNAWARE)
	is_in_grace_period = false
	friendly_knowledge.grace_period_alarmer = null


## Checks whether the unit is alarmed.
func is_alarmed() -> bool:
	return awareness_level == AwarenessLevel.ALARMED


## Checks whether the unit is alerted.
func is_alerted() -> bool:
	return awareness_level == AwarenessLevel.ALERTED


## Checks whether the unit is unaware.
func is_unaware() -> bool:
	return awareness_level == AwarenessLevel.UNAWARE