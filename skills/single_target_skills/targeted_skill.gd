## A skill which creates a list of valid targets and requires one be selected before it can be used.
@abstract class_name TargetedSkill
extends Skill

## The type of this skill, determining what targets it can be used on.
@export var skill_type := SkillType.GENERAL

## An array of potential targets which are currently valid for this skill.
var potential_targets : Array[Unit] = []
## The currently selected target.
var target : Unit

func get_usability() -> bool:
	return !!target


func arm() -> void:
	super()
	get_all_targets()
	Events.target_selected.connect(retarget)
	get_usability()


func disarm() -> void:
	super()
	Events.target_selected.disconnect(retarget)
	potential_targets = []
	clear_target()


## Updates the list of viable targets based on this skill's custom rules.
@abstract func get_all_targets() -> void


## Target the skill to a particular unit, change all necessary variables.
func retarget(new_target : Unit) -> void:
	target = new_target
	if target:
		World.level.target_retical.visible = true
		World.level.target_retical.global_position = target.global_position
		World.level.level_camera.jump_to_point(target.global_position)
	else:
		clear_target()
	Events.recheck_skill_usability.emit()


## Reset the target to null.
func clear_target() -> void:
	target = null
	World.level.level_camera.fix_to_actor(World.level.active_unit)
	World.level.target_retical.visible = false


## Filter targets based on this skill being intended only for enemies unaware of the active player unit.
func _filter_stealth(target_unit : Unit) -> bool:
	if target_unit is EnemyUnit:
		return !target_unit.awareness.targeted_friendlies.has(user)
	return true


## Filter targets based on this skill being intended only for enemies aware of the active player unit.
func _filter_combat(target_unit : Unit) -> bool:
	if target_unit is EnemyUnit:
		return target_unit.awareness.targeted_friendlies.has(user)
	return true


## Filter the available targets based on the type of the skill. Should be used at the end of the [get_all_targets] method.
func _filter_targets(targets : Array[Unit]) -> Array[Unit]:
	if skill_type == SkillType.COMBAT:
		return targets.filter(_filter_combat)
	if skill_type == SkillType.STEALTH:
		return targets.filter(_filter_stealth)
	return targets