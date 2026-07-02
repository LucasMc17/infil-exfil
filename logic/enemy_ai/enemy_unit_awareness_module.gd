## Logic module for handling an individual enemy unit's awareness of the intruding friendlies. This operates in conjunction with the [EnemyTeamAwarenessModule] (which handles team-level awareness) to inform the overall alertness state of the enemy team.
class_name EnemyUnitAwarenessModule
extends Resource

## Signal emitted when the enemy's awareness is changed, either escalating or de-escalating.
signal awareness_changed(old_awareness : AwarenessLevel, new_awareness : AwarenessLevel)

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
		awareness_changed.emit(awareness_level, val)
		awareness_level = val
		unit.debug_label.change_param('awareness_level', AwarenessLevel.find_key(val))
## The unit to whom this awareness module belongs.
var unit : EnemyUnit
## The [FriendlyUnit]s which the Enemy is aware of specifically. This should always be an empty array unless the Unit is in the [ALARMED] [AwarenessLevel].
var targeted_friendlies : Array[FriendlyUnit] = []
## How many friendlies the unit is actively aware of/in combat with at this moment.
var targeted_friendly_count : int:
	get():
		return targeted_friendlies.size()

func _init(u : EnemyUnit) -> void:
	unit = u


## Update the unit's awareness level to [ALERTED]
func alert():
	awareness_level = AwarenessLevel.ALERTED
	targeted_friendlies = []
	unit.debug_label.change_param('targets', '[]')


## Update the unit's awareness level to [ALARMED], instantly stopping the unit if they are moving, and adding all sighted friendlies to their list of targets.
func alarm(spotted_friendlies : Array[FriendlyUnit] = []):
	if !is_alarmed():
		awareness_level = AwarenessLevel.ALARMED
		unit.movement_machine.current_state.transition('NoMovement')
		unit.forfeit_turn()
	for friendly : FriendlyUnit in spotted_friendlies:
		if !targeted_friendlies.has(friendly):
			targeted_friendlies.append(friendly)
	unit.debug_label.change_param('targets', '[' + ', '.join(targeted_friendlies.map(func (friendly): return friendly.name)) + ']')


## Update the unit's awareness level to [UNAWARE], clearing their list of targets.
func drop_guard():
	awareness_level = AwarenessLevel.UNAWARE
	targeted_friendlies = []
	unit.debug_label.change_param('targets', '[]')


## Checks whether the unit is alarmed.
func is_alarmed() -> bool:
	return awareness_level == AwarenessLevel.ALARMED


## Checks whether the unit is alerted.
func is_alerted() -> bool:
	return awareness_level == AwarenessLevel.ALERTED


## Checks whether the unit is unaware.
func is_unaware() -> bool:
	return awareness_level == AwarenessLevel.UNAWARE