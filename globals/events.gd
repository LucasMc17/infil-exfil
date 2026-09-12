## Global events system.
extends Node

## Signal emitted when a level finishes loading in.
signal level_loaded()

## Signal emitted when a unit on either team is activated.
signal unit_activated(unit : Unit)

## Signal emitted when a unit on either team is deactivated.
signal unit_deactivated(unit : Unit)

## Signal emitted when a unit on either team moves for any reason.
signal unit_moved()

## Signal emitted when a unit on either team takes any action.
signal unit_acted()

# Player turn events

## Signal emitted when the player's turn ends.
signal player_turn_ended()

## Signal emitted when the player arms a unit's skill for use.
signal skill_armed(skill : Skill)

## Signal emitted when a target is selected for an armed [SingleTargetSkill].
signal target_selected(target : EnemyUnit)

## Signal emitted to request a refresh of the available skills for the active unit.
signal refresh_unit_skills()

## Trigger the armed skill UI to recheck for skill usability, and enable confirm button if true.
signal recheck_skill_usability()

## Signal emitted when the armed [SingleTargetSkill]'s target is cleared.
signal target_cleared()

## Signal emitted when the player uses a skill. Fired in conjunction with more specific skill events below
signal skill_used(skill : Skill)

## Signal emitted when the player disarms the active units armed skill.
signal skill_disarmed()

## Emitted when a pathing waymarker is placed by the player.
signal waymarker_placed()

## Emitted when the player's planned path is cleared.
signal planned_path_cleared()

# Enemy turn events

## Signal emitted when the enemy's turn ends. Since the player acts first, this also acts as the end point of a "set" of turns, and is the point at which turn based timers should increment.
signal enemy_turn_ended()

## Signal emitted when the enemy raises an alarm.
signal alarm_raised(raiser : Unit)

## Signal emitted when the enemy's alarm is canceled.
signal alarm_ended()

# Unit Lifecycle

## Signal emitted when a unit is disabled, either by dying, being taken captive, or losing consciousness.
signal unit_disabled(unit : Unit)

## Signal emitted when a unit dies.
signal unit_died(unit : Unit)

## Signal emitted when a unit is taken captive.
signal unit_taken_captive(unit : Unit)

## Signal emitted when a unit loses consciousness.
signal unit_lost_consciousness(unit : Unit)

# Debug

## Emitted when the debug alarm monitor needs to be refreshed.
signal update_alarm_monitor()

## Emitted when a unit's information changes and a request should be fired to refresh the debug unit inspector, if its current unit is the one that fired this signal.
signal request_update_unit_monitor(unit : EnemyUnit)