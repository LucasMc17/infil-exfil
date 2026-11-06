## Module responsible for tracking an [EnemyUnit]'s entire knowledge base about the presence of specific [FriendlyUnit]s within the level. This includes known friendlies in the unit's sight, known friendlies who have broken line of sight but are still known, and the locations of incapacitated units.
class_name FriendlyKnowledgeModule
extends Object

## Class representing a friendly which was seen in this alarm phase. Includes info about whether or not the unit is still in sight, and its last known position if not. Has utility methods for updating its own information.
class FriendlySighting:
	## The sighted friendly unit.
	var friendly : FriendlyUnit
	## Whether the enemy unit still has eyes on the friendly.
	var still_in_sight := true
	## The last known position of the sighted friendly. If they are still in sight, this should be the friendly's current board position.
	var last_known_position : Vector3i
	## The NavZone in which the above last_known_position is situated, for use in dialog barks and certain other functions.
	var last_known_zone : NavZone
	## Whether the enemy has confirmed the sighted unit to be incapacitated.
	var confirmed_incapacitated := false
	
	func _init(seen_friendly : FriendlyUnit) -> void:
		friendly = seen_friendly
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

## The awareness module which initiated this submodule
var awareness : EnemyUnitAwarenessModule
## The unit which this module corresponds to.
var unit : EnemyUnit
## The [FriendlyUnit]s which the Enemy is aware of specifically. This should always be an empty dictionary unless the Unit is in the [ALARMED] [AwarenessLevel].
var targeted_friendlies : Dictionary[int, FriendlySighting] = {}
## How many friendlies the unit is actively aware of/in combat with at this moment.
var targeted_friendly_count : int:
	get():
		return targeted_friendlies.size()
## The targeted friendlies which are still in this unit's sights and not known to be incapacitated.
var friendlies_in_sight : Array[FriendlySighting]:
	get():
		return targeted_friendlies.values().filter(func(sighting : FriendlySighting): return sighting.still_in_sight and !sighting.confirmed_incapacitated)
## The targeted friendlies which are not currently in this unit's sights and are not known to be incapacitated.
var friendlies_out_of_sight : Array[FriendlySighting]:
	get():
		return targeted_friendlies.values().filter(func(sighting : FriendlySighting): return !sighting.still_in_sight and !sighting.confirmed_incapacitated)
## True if there are currently no active friendlies in sight of this unit.
var no_friendlies_in_sight : bool:
	get():
		return friendlies_in_sight.is_empty()
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
	awareness = a
	unit = awareness.unit
	Events.unit_moved.connect(confirm_all_sightings)
	Events.player_turn_ended.connect(_resolve_suppression)


## Confirms an individual sighting so that the unit can keep an up to date list of which spotted player units are still in sight and which are out of sight.
func _confirm_sighting(sighting : FriendlySighting) -> void:
	var can_see : bool
	var target_incapacitated = sighting.friendly.is_incapacitated()
	if sighting.friendly.position.distance_to(unit.position) <= 15.0 and \
	unit.seeing_zone.get_visibility_of_seen_zone(sighting.friendly.seen_zone):
		can_see = true
		
		has_pursued = false
		sighting.still_in_sight = true
		sighting.last_known_position = sighting.friendly.board_position
		sighting.last_known_zone = Level.current.get_zone_from_position(sighting.last_known_position)
		if target_incapacitated:
			sighting.confirmed_incapacitated = true
		else:
			awareness.friendly_spotted.emit(sighting.friendly)
			Events.friendly_spotted.emit()
	else:
		can_see = false
		sighting.still_in_sight = false
	if suppression_target == sighting.friendly and !target_incapacitated:
		unit.suppression_indicator.check_los(can_see)
	
	if can_see and !target_incapacitated and (!last_poc or last_poc.position != unit.board_position):
		last_poc = ContactPoint.new(unit.board_position)


## Remove suppression at the end of the player turn if the suppression target is no longer in sight.
func _resolve_suppression() -> void:
	if !unit.suppression_indicator.los_clear:
		lose_suppression()


## Returns true if the unit is alerted to the passed friendly.
func is_aware_of(friendly : FriendlyUnit) -> bool:
	return targeted_friendlies.has(friendly.get_instance_id())


## For each friendly the unit has seen within this alert phase, confirm they are still in sight. Useful when this unit moves and needs to recheck who they can see.[br]
## Note that, in order to be in sight, the unit does not have to be directly looking at the friendly. There only needs to be a clear theoretical line of sight between them, and the unit must be within 15 meters of the target.[br]
## If the unit is still in sight, the sighting will update its last known position. If not, it will mark the unit as out of sight and cease updating its last known position.
func confirm_all_sightings() -> void:
	if unit.is_incapacitated() or !awareness.is_alarmed():
		return
	for sighting : FriendlySighting in targeted_friendlies.values():
		_confirm_sighting(sighting)
	Events.request_update_unit_monitor.emit(unit)


## Handles all necessary updates to the friendly knowledge base upon seeing [FriendlyUnit]s.
func handle_seen_friendlies(friendlies : Array[FriendlyUnit], should_skip_grace_period) -> void:
	for friendly in friendlies:
		var friendly_id = friendly.get_instance_id()
		if !targeted_friendlies.has(friendly_id):
			var sighting = FriendlySighting.new(friendly)
			if !should_skip_grace_period and !grace_period_alarmer:
				grace_period_alarmer = sighting
			if friendlies_in_sight.is_empty() and should_skip_grace_period:
				unit.react_to_sighting(sighting.last_known_zone, !awareness.has_seen_enemies)
			targeted_friendlies[friendly_id] = sighting


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
	targeted_friendlies.clear()
	last_poc = null
	has_pursued = false
