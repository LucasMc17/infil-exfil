## A skill which creates a list of valid targets and requires one be selected before it can be used.
@abstract class_name TargetedSkill
extends Skill

## The type of this skill, determining what targets it can be used on.
@export var skill_type := SkillType.GENERAL
## A list of filters (as defined in the [TargetFilters] class) to apply to all potential targets for this skill. For a small performance optimization, list the filters in order from simplest most complex.
@export var target_filters : Array[TargetFilters.FilterName] = [
	TargetFilters.FilterName.OFFENSE_SUITE
]

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


func arm_as_enemy() -> void:
	super()
	get_all_targets()


func disarm() -> void:
	super()
	Events.target_selected.disconnect(retarget)
	potential_targets = []
	clear_target()


func disarm_as_enemy() -> void:
	super()
	potential_targets = []
	clear_target()


func setup_overrides(overrides : Dictionary) -> void:
	get_all_targets()
	var chosen_target = overrides.get("target")
	if !potential_targets.has(chosen_target):
		DebugConsole.error('Skill overrides set up with target not listed in potential targets!')
		return
	target = chosen_target


func begin_use() -> void:
	super()
	target = null
	potential_targets = []


## Updates the list of viable targets based on this skill's custom rules.
@abstract func get_all_targets() -> void


## Probes the given position for viability when targeting a specific unit by approximating what the get_all_targets function would return at that position. Used by AI-controlled units to judge viable movements before using a skill.
@abstract func judge_position(test_position : Vector3i, test_target : Unit) -> bool


## Target the skill to a particular unit, change all necessary variables.
func retarget(new_target : Unit) -> void:
	target = new_target
	if target:
		Level.current_level.target_retical.visible = true
		Level.current_level.target_retical.global_position = target.global_position
		Level.current_level.level_camera.jump_to_point(target.global_position)
	else:
		clear_target()
	Events.recheck_skill_usability.emit()


## Reset the target to null.
func clear_target() -> void:
	target = null
	Level.current_level.level_camera.fix_to_actor(Unit.active_unit)
	Level.current_level.target_retical.visible = false


## Filter the available targets based on the type of the skill. Should be used at the end of the [get_all_targets] method.
func _filter_targets(targets : Array[Unit]) -> Array[Unit]:
	return TargetFilters.apply_filters(target_filters, targets, user)