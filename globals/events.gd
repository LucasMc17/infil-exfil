## Global events system.
extends Node

## Signal emitted when a unit on either team is activated.
signal unit_activated(unit : Unit)

# Player turn events

## Signal emitted when the player's turn ends.
signal player_turn_ended()

## Signal emitted when the player arms a unit's skill for use.
signal skill_armed(skill : Skill)

## Signal emitted when a target is selected for an armed [SingleTargetSkill].
signal target_selected(target : EnemyUnit)

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

## Signal emitted when the enemy raises an alarm.
signal alarm_raised(alarm, raiser : EnemyUnit)

## Signal emitted when the enemy's alarm is canceled.
signal alarm_ended()
