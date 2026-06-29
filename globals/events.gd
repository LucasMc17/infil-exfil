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
signal target_selected(targeter : FriendlyUnit, target : EnemyUnit)

## Signal emitted when the armed [SingleTargetSkill]'s target is cleared.
signal target_cleared()

## Signal emitted when the player uses a skill. Fired in conjunction with more specific skill events below
signal skill_used(skill : Skill, user : Unit)

## Signal emitted when the player uses a [TargetlessSkill]. Fired in conjunction with the general [skill_used] event above.
signal targetless_skill_used(skill : TargetlessSkill, user : Unit)

## Signal emitted when the player uses a [SingleTargetSkill]. Fired in conjunction with the general [skill_used] event above.
signal single_target_skill_used(skill : SingleTargetSkill, user : Unit, target : Unit)

## Signal emitted when the player disarms the active units armed skill.
signal skill_disarmed()

# Enemy turn events

## Signal emitted when the enemy raises an alarm.
signal alarm_raised(alarm, raiser : EnemyUnit)

## Signal emitted when the enemy's alarm is canceled.
signal alarm_ended()