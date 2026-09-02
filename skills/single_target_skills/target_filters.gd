## Class for applying many filters to a list of potential targets in order to determine valid targets of [TargetedSkill]s.
class_name TargetFilters
extends Object

## A list of filter names descriptive of what kind of potential targets they filter out. Note that some filters assume that either the targeted or the targeter is a particular subclass of [Unit] ([FriendlyUnit] or [EnemyUnit]) and will simply return true if these assumptions are not met.
enum FilterName {
	## Only [FriendlyUnit]s will be considered valid targets.
	FRIENDLIES_ONLY,
	## Only [EnemyUnit]s will be considered valid targets.
	ENEMIES_ONLY,
	## Only [Unit]s on the opposite team as the targeting unit will be considered valid targets.
	OTHER_TEAM_ONLY,
	## Only [Unit]s on the same team as the targeting unit will be considered valid targets.
	SAME_TEAM_ONLY,
	## Assumes targeter is a [FriendlyUnit] and targeted is an [EnemyUnit]. Target will only be considered valid if it is not currently suppressing the targeter.
	NO_SUPPRESSORS,
	## Assumes targeter is a [FriendlyUnit] and targeted is an [EnemyUnit]. Target will only be considered valid if it is not alerted to the targeter.
	UNALARMED_ENEMIES_ONLY,
	## Assumes targeter is a [FriendlyUnit] and targeted is an [EnemyUnit]. Target will only be considered valid if it is alerted to the targeter.
	ALARMED_ENEMIES_ONLY,
	## Target will only be considered valid if there is a clear line of sight from the targeter to the targeted.
	IN_SIGHT_ONLY,
	## Assumes targeter is an [EnemyUnit] and targeted is a [FriendlyUnit]. 
	SPOTTED_FRIENDLIES_ONLY
}

## Dictionary mapping the above [FilterName]s to their respective callable.
static var _FILTER_DICT : Dictionary[FilterName, Callable] = {
	FilterName.FRIENDLIES_ONLY: _filter_friendlies_only,
	FilterName.ENEMIES_ONLY: _filter_enemies_only,
	FilterName.OTHER_TEAM_ONLY: _filter_other_team_only,
	FilterName.SAME_TEAM_ONLY: _filter_same_team_only,
	FilterName.NO_SUPPRESSORS: _filter_no_suppressors,
	FilterName.UNALARMED_ENEMIES_ONLY: _filter_unalarmed_enemies_only,
	FilterName.ALARMED_ENEMIES_ONLY: _filter_alarmed_enemies_only,
	FilterName.IN_SIGHT_ONLY: _filter_in_sight_only,
	FilterName.SPOTTED_FRIENDLIES_ONLY: _filter_spotted_friendlies_only
}

## Applies a list of [FilterName]s to a list of potential targets and filters out all that fail any of the filters. Note that this is the one and only public method of this class.
static func apply_filters(filters : Array[FilterName], targeted : Array[Unit], targeter : Unit) -> Array[Unit]:
	return targeted.filter(func (target): return _apply_filters_to_single_target(filters, target, targeter))


## Apply a list of filters to a single potential target, returning true if the target passes all filters, and false otherwise. For use in the above [apply_filters] method.
static func _apply_filters_to_single_target(filters : Array[FilterName], targeted : Unit, targeter : Unit) -> bool:
	for filter in filters:
		if !_FILTER_DICT[filter].call(targeted, targeter):
			return false
	return true

# Filter funcs - the below are semantically named utility methods for applying the filters described by the [FilterName] they correspond to. Each should take in a [targeted] unit and a [targeter] unit, and each should return a boolean indicating whether the filter allowed the target through or not.

static func _filter_friendlies_only(targeted : Unit, _targeter : Unit) -> bool:
	return targeted is FriendlyUnit


static func _filter_enemies_only(targeted : Unit, _targeter : Unit) -> bool:
	return targeted is EnemyUnit


static func _filter_other_team_only(targeted : Unit, targeter : Unit) -> bool:
	if targeter is FriendlyUnit:
		return targeted is EnemyUnit
	return targeted is FriendlyUnit


static func _filter_same_team_only(targeted : Unit, targeter : Unit) -> bool:
	if targeter is FriendlyUnit:
		return targeted is FriendlyUnit
	return targeted is EnemyUnit


static func _filter_no_suppressors(targeted : Unit, targeter : Unit) -> bool:
	if targeter is not FriendlyUnit or targeted is not EnemyUnit:
		return true
	return !targeter.is_suppressed_by(targeted)


static func _filter_unalarmed_enemies_only(targeted : Unit, targeter : Unit) -> bool:
	if targeter is not FriendlyUnit or targeted is not EnemyUnit:
		return true
	return !targeted.awareness.is_aware_of(targeter)


static func _filter_alarmed_enemies_only(targeted : Unit, targeter : Unit) -> bool:
	if targeter is not FriendlyUnit or targeted is not EnemyUnit:
		return true
	return targeted.awareness.is_aware_of(targeter)


static func _filter_in_sight_only(targeted : Unit, targeter : Unit) -> bool:
	return targeter.seen_zone.get_line_of_sight(targeted.seen_zone.global_position, targeted)


static func _filter_spotted_friendlies_only(targeted : Unit, targeter : Unit) -> bool:
	if targeter is not EnemyUnit or targeted is not FriendlyUnit:
		return true
	return targeter.awareness.is_aware_of(targeted)