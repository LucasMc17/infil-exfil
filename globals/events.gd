extends Node

signal unit_activated(unit : Unit)

# Player turn events

signal player_turn_ended()

signal skill_armed(skill : Skill)

signal skill_used(skill : Skill, user : Unit)

signal target_selected(targeter : FriendlyUnit, target : EnemyUnit)

signal target_cleared()

signal targetless_skill_used(skill : TargetlessSkill, user : Unit)

signal single_target_skill_used(skill : SingleTargetSkill, user : Unit, target : Unit)

signal skill_disarmed()

# Enemy turn events


# signal enemy_turn_ended()

# signal enemy_action_finished(enemy : EnemyUnit)

# Alarms

# TODO: alarm will be its own custom type.
signal alarm_raised(alarm, raiser : EnemyUnit)

signal alarm_ended()