## Abstract ancestor class of the Player and Enemy Knowledge Modules.
@abstract class_name UnitKnowledgeModule
extends Object

@abstract class Sighting:
	var unit : Unit
	## Whether the enemy unit still has eyes on this unit.
	var still_in_sight := true
	## The last known position of the sighted unit. If they are still in sight, this should be the unit's current board position.
	var last_known_position : Vector3i
	## The NavZone in which the above last_known_position is situated, for use in dialog barks and certain other functions.
	var last_known_zone : NavZone

	func _init(seen_unit : Unit) -> void:
		unit = seen_unit

## The awareness module which initiated this submodule
var awareness : EnemyUnitAwarenessModule
## The unit which this module corresponds to.
var unit : EnemyUnit
## All the sightings this module is currently maintaining.
var sightings : Dictionary[int, Sighting] = {}
## How many friendlies the unit is actively aware of/in combat with at this moment.
var sightings_count : int:
	get():
		return sightings.size()
## The targeted friendlies which are still in this unit's sights and not known to be incapacitated.
var all_in_sight : Array[Sighting]:
	get():
		return sightings.values().filter(func(sighting : Sighting): return sighting.still_in_sight and !sighting.confirmed_incapacitated)
## The targeted friendlies which are not currently in this unit's sights and are not known to be incapacitated.
var all_out_of_sight : Array[Sighting]:
	get():
		return sightings.values().filter(func(sighting : Sighting): return !sighting.still_in_sight and !sighting.confirmed_incapacitated)
## True if there are currently no active friendlies in sight of this unit.
var has_none_in_sight : bool:
	get():
		return all_in_sight.is_empty()

func _init(a : EnemyUnitAwarenessModule) -> void:
	awareness = a
	unit = awareness.unit
	Events.unit_moved.connect(confirm_all_sightings)


## For each friendly the unit has seen within this alert phase, confirm they are still in sight. Useful when this unit moves and needs to recheck who they can see.[br]
## Note that, in order to be in sight, the unit does not have to be directly looking at the friendly. There only needs to be a clear theoretical line of sight between them, and the unit must be within 15 meters of the target.[br]
## If the unit is still in sight, the sighting will update its last known position. If not, it will mark the unit as out of sight and cease updating its last known position.
func confirm_all_sightings() -> void:
	if unit.is_incapacitated() or !awareness.is_alarmed():
		return
	for sighting : Sighting in sightings.values():
		_confirm_sighting(sighting)
	Events.request_update_unit_monitor.emit(unit)


## Confirms an individual sighting so that the unit can keep an up to date list of units have been spotted, as well as which ones are in sight and which are out of sight.
func _confirm_sighting(sighting : Sighting) -> void:
	var target_incapacitated = sighting.unit.is_incapacitated()
	if sighting.unit.position.distance_to(unit.position) <= 15.0 and \
	unit.seeing_zone.get_visibility_of_seen_zone(sighting.unit.seen_zone):
		sighting.still_in_sight = true
		sighting.last_known_position = sighting.unit.board_position
		sighting.last_known_zone = Level.current.get_zone_from_position(sighting.last_known_position)
		if target_incapacitated:
			# MARK
			sighting.confirmed_incapacitated = true
		_on_sighting_confirmed(sighting, sighting)
	else:
		sighting.still_in_sight = false
		_on_sighting_not_confirmed(sighting, sighting)


## Executed when a sighting is confirmed.
func _on_sighting_confirmed(_sighting : Sighting, _inherited_sighting) -> void:
	pass


## Executed when a sighting is rechecked and determined to be unconfirmed (not currently in sight).
func _on_sighting_not_confirmed(_sighting : Sighting, _inherited_sighting) -> void:
	pass
	