## Module responsible for tracking an [EnemyUnit]'s entire knowledge base about the presence of specific [FriendlyUnit]s within the level. This includes known friendlies in the unit's sight, known friendlies who have broken line of sight but are still known, and the locations of incapacitated units.
class_name FriendlyKnowledgeModule
extends UnitKnowledgeModule

## Class representing a friendly which was seen in this alarm phase. Includes info about whether or not the unit is still in sight, and its last known position if not. Has utility methods for updating its own information.
class FriendlySighting extends Sighting:
	## The sighted friendly unit.
	var friendly : FriendlyUnit:
		get():
			return unit
	## Whether the enemy has confirmed the sighted unit to be incapacitated.
	var confirmed_incapacitated := false
	
	func _init(seen_friendly : FriendlyUnit) -> void:
		super(seen_friendly)
		still_in_sight = true
		last_known_position = friendly.board_position
		last_known_zone = Level.current.get_zone_from_position(last_known_position)

## Class representing where the unit was last standing when actively encountering friendlies. Updated by the confirm_all_sightings function if it detects that a unit is still in sight.
class ContactPoint:
	## The position (in board terms) where the unit was standing when last encountering enemies.
	var position : Vector3i
	## The NavZone which the above position is in.
	var nav_zone : NavZone

	func _init(p : Vector3i) -> void:
		position = p
		nav_zone = Level.current.get_zone_from_position(p)

## The last known point of contact with the friendly team, if any.
var last_poc : ContactPoint:
	set(val):
		last_poc = val
		Events.request_update_unit_monitor.emit(unit)
## The unit this target is currently suppressing, if any.
var suppression_target : FriendlyUnit
## The unit sighting which was created to trigger this unit entering their alarm grace period.
var grace_period_alarmer : FriendlyKnowledgeModule.FriendlySighting
## Whether the unit has already given chase to a friendly unit in this alarm phase. Resets to false when seeing an enemy unit.
var has_pursued := false

func _init(a : EnemyUnitAwarenessModule) -> void:
	super(a)
	Events.player_turn_ended.connect(_resolve_suppression)


func _on_sighting_confirmed(_sighting : Sighting, friendly_sighting : FriendlySighting = null) -> void:
	awareness.friendly_spotted.emit(friendly_sighting.friendly)
	Events.friendly_spotted.emit()
	unit.suppression_indicator.check_los(true)
	has_pursued = false
	if (!last_poc or last_poc.position != unit.board_position):
		last_poc = ContactPoint.new(unit.board_position)


func _on_sighting_not_confirmed(_sighting : Sighting, friendly_sighting : FriendlySighting = null) -> void:
	unit.suppression_indicator.check_los(false)


## Remove suppression at the end of the player turn if the suppression target is no longer in sight.
func _resolve_suppression() -> void:
	if !unit.suppression_indicator.los_clear:
		lose_suppression()


## Returns true if the unit is alerted to the passed friendly.
func is_aware_of(friendly : FriendlyUnit) -> bool:
	return sightings.has(friendly.get_instance_id())


## Handles all necessary updates to the friendly knowledge base upon seeing [FriendlyUnit]s.
func handle_seen_friendlies(friendlies : Array[FriendlyUnit], should_skip_grace_period) -> void:
	for friendly in friendlies:
		var friendly_id = friendly.get_instance_id()
		if !sightings.has(friendly_id):
			var sighting = FriendlySighting.new(friendly)
			if !should_skip_grace_period and !grace_period_alarmer:
				grace_period_alarmer = sighting
			if all_in_sight.is_empty() and should_skip_grace_period:
				unit.react_to_sighting(sighting.last_known_zone, !awareness.has_seen_enemies)
			sightings[friendly_id] = sighting


## Apply suppression to a target.
func suppress_target(target : FriendlyUnit) -> void:
	suppression_target = target
	unit.suppression_indicator.activate(target)


## Clear this unit's currently suppressed target.
func lose_suppression() -> void:
	suppression_target = null
	unit.suppression_indicator.deactivate()


## Clear the known friendly's list and reset the last point of contact. 
func reset_friendly_knowledge() -> void:
	lose_suppression()
	grace_period_alarmer = null
	sightings.clear()
	last_poc = null
	has_pursued = false
