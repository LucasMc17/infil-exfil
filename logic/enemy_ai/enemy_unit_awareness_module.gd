## Logic module for handling an individual enemy unit's awareness of the intruding friendlies. This operates in conjunction with the [EnemyTeamAwarenessModule] (which handles team-level awareness) to inform the overall alertness state of the enemy team.
class_name EnemyUnitAwarenessModule
extends Resource

## Signal emitted when the enemy's awareness is changed, either escalating or de-escalating.
signal awareness_changed(old_awareness : AwarenessLevel, new_awareness : AwarenessLevel)

## Class representing a friendly which was seen in this alarm phase. Includes info about whether or not the unit is still in sight, and its last known position if not. Has utility methods for updating its own information.
class FriendlySighting:
	## The sighted friendly unit.
	var friendly : FriendlyUnit
	## Whether the enemy unit still has eyes on the friendly.
	var still_in_sight := true
	## The last known position of the sighted friendly. If they are still in sight, this should be the friendly's current board position.
	var last_known_position : Vector3i
	## Whether the enemy has confirmed the sighted unit to be incapacitated.
	var confirmed_incapacitated := false
	
	func _init(seen_friendly : FriendlyUnit) -> void:
		friendly = seen_friendly
		still_in_sight = true
		last_known_position = friendly.board_position


## Class representing where the unit was last standing when actively encountering friendlies. Updated by the confirm_all_sightings function if it detects that a unit is still in sight.
class ContactPoint:
	## The position (in board terms) where the unit was standing when last encountering enemies.
	var position : Vector3i
	## The NavZone which the above position is in.
	var nav_zone : NavZone

	func _init(p : Vector3i) -> void:
		position = p
		nav_zone = Level.current_level.get_zone_from_position(p)


## The possible awareness states which an enemy unit can operate under.
enum AwarenessLevel {
	## No knowledge whatsoever of friendlies-- no alert.
	UNAWARE,
	## Aware of friendly presence, but not of their general position-- high alert.
	ALERTED,
	## Aware of friendly presence and of their general or specific position-- either in combat or moving towards combat.
	ALARMED
}

## The enemy's current awareness level.
var awareness_level := AwarenessLevel.UNAWARE:
	set(val):
		var old_val = awareness_level
		awareness_level = val
		unit.debug_label.change_param('awareness_level', AwarenessLevel.find_key(val))
		awareness_changed.emit(old_val, val)
		Events.request_update_unit_monitor.emit(unit)
## The unit to whom this awareness module belongs.
var unit : EnemyUnit
## Whether or not the unit will first attempt to detain friendly units when encountering them.
var will_attempt_to_detain := true
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
## The unit this target is currently suppressing, if any.
var suppression_target : FriendlyUnit
## The last known point of contact with the friendly team, if any.
var last_poc : ContactPoint:
	set(val):
		last_poc = val
		Events.request_update_unit_monitor.emit(unit)
## Whether the unit is in the detection grace period. This occurs when the unit sees a friendly unit during the player turn. While in the grace period, stealth skills are still usable on this unit. The grace period ends as soon as the enemy unit begins its next turn.
var is_in_grace_period := false
## Whether the unit has already given chase to a friendly unit in this alarm phase. Resets to false when seeing an enemy unit.
var has_pursued := false

func _init(u : EnemyUnit) -> void:
	unit = u
	Events.unit_moved.connect(confirm_all_sightings)
	Events.player_turn_ended.connect(resolve_suppression)


func _confirm_sighting(sighting : FriendlySighting) -> void:
	var can_see : bool
	var target_incapacitated = sighting.friendly.is_incapacitated()
	if sighting.friendly.position.distance_to(unit.position) <= 15.0 and \
	unit.seeing_zone.get_line_of_sight(sighting.friendly.seen_zone.global_position, sighting.friendly):
		can_see = true
		has_pursued = false
		sighting.still_in_sight = true
		sighting.last_known_position = sighting.friendly.board_position
		if target_incapacitated:
			sighting.confirmed_incapacitated = true
	else:
		can_see = false
		sighting.still_in_sight = false
	if suppression_target == sighting.friendly and !target_incapacitated:
		unit.suppression_indicator.check_los(can_see)
	
	if can_see and !target_incapacitated and (!last_poc or last_poc.position != unit.board_position):
		last_poc = ContactPoint.new(unit.board_position)


## Returns true if the unit is alerted to the passed friendly.
func is_aware_of(friendly : FriendlyUnit) -> bool:
	return targeted_friendlies.has(friendly.get_instance_id())


## Apply suppression to a target.
func suppress_target(target : FriendlyUnit) -> void:
	suppression_target = target
	unit.suppression_indicator.activate(target)


## Clear this unit's currently suppressed target.
func lose_suppression() -> void:
	suppression_target = null
	unit.suppression_indicator.deactivate()


## Update the unit's awareness level to [ALERTED].
func alert():
	lose_suppression()
	is_in_grace_period = false
	awareness_level = AwarenessLevel.ALERTED
	targeted_friendlies.clear()
	has_pursued = false
	last_poc = null
	unit.debug_label.change_param('targets', '[]')
	Events.request_update_unit_monitor.emit(unit)


## Update the unit's awareness level to [ALARMED], instantly stopping the unit if they are moving, and adding all sighted friendlies to their list of targets.
func alarm(spotted_friendlies : Variant = [], skip_grace_period := false):
	if spotted_friendlies is FriendlyUnit:
		spotted_friendlies = [spotted_friendlies]
	if !is_alarmed():
		if !skip_grace_period:
			is_in_grace_period = true
		awareness_level = AwarenessLevel.ALARMED
		unit.stop_moving()
		if unit.is_active:
			unit.forfeit_turn()
	for friendly : FriendlyUnit in spotted_friendlies:
		var friendly_id = friendly.get_instance_id()
		if !targeted_friendlies.has(friendly_id):
			targeted_friendlies[friendly_id] = FriendlySighting.new(friendly)
	unit.debug_label.change_param('targets', '[' + ', '.join(targeted_friendlies.values().map(func (sighting): return sighting.friendly.name)) + ']')
	Events.request_update_unit_monitor.emit(unit)


## Update the unit's awareness level to [UNAWARE], clearing their list of targets.
func drop_guard():
	lose_suppression()
	is_in_grace_period = false
	awareness_level = AwarenessLevel.UNAWARE
	targeted_friendlies.clear()
	has_pursued = false
	last_poc = null
	unit.debug_label.change_param('targets', '[]')
	Events.request_update_unit_monitor.emit(unit)


## Reset the grace period bool to false.
func resolve_grace_period():
	is_in_grace_period = false


## Remove suppression at the end of the player turn if the suppression target is no longer in sight.
func resolve_suppression() -> void:
	if !unit.suppression_indicator.los_clear:
		lose_suppression()


## For each friendly the unit has seen within this alert phase, confirm they are still in sight. Useful when this unit moves and needs to recheck who they can see.[br]
## Note that, in order to be in sight, the unit does not have to be directly looking at the friendly. There only needs to be a clear theoretical line of sight between them, and the unit must be within 15 meters of the target.[br]
## If the unit is still in sight, the sighting will update its last known position. If not, it will mark the unit as out of sight and cease updating its last known position.
func confirm_all_sightings() -> void:
	if unit.is_incapacitated() or !is_alarmed():
		return
	for sighting : FriendlySighting in targeted_friendlies.values():
		_confirm_sighting(sighting)
	Events.request_update_unit_monitor.emit(unit)


## Checks whether the unit is alarmed.
func is_alarmed() -> bool:
	return awareness_level == AwarenessLevel.ALARMED


## Checks whether the unit is alerted.
func is_alerted() -> bool:
	return awareness_level == AwarenessLevel.ALERTED


## Checks whether the unit is unaware.
func is_unaware() -> bool:
	return awareness_level == AwarenessLevel.UNAWARE