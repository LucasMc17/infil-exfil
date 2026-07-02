## Logic module for handling the skill currently being armed and/or targeted in a level. Also tracks the unit which is arming it as well as the currently selected target. Only relevant when the player is using a skill, as opposed to the enemy AI, which does not require UI feedback for targeting.
class_name SkillTargetingModule
extends Resource

## The currently armed skill, which the player is considering using.
var armed_skill : Skill
## The [FriendlyUnit] arming the skill, if one is currently armed.
var skill_user : FriendlyUnit:
	get():
		if armed_skill:
			return World.level.active_unit
		else:
			return null
## The target of the current skill, if it is a single target skill.
var current_target : EnemyUnit
## Reference to the match ui currently loaded in the level.
var _match_ui : MatchUI:
	get():
		return World.level.match_ui

func _init() -> void:
	Events.skill_armed.connect(_arm_skill)
	Events.skill_disarmed.connect(_clear)
	
	Events.target_selected.connect(_target_selected)
	Events.target_cleared.connect(_clear_target)


func _clear() -> void:
	if armed_skill:
		_clear_target()
		armed_skill = null
		_match_ui.disarm_skill_ui()


func _clear_target() -> void:
	if current_target:
		World.level.level_camera.fix_to_actor(World.level.active_unit)
		World.level.target_retical.visible = false
		current_target = null


func _arm_skill(skill : Skill) -> void:
	armed_skill = skill
	DebugConsole.log(skill_user)
	skill.arm()
	_match_ui.arm_skill_ui(skill)


func _target_selected(_targeter: FriendlyUnit, target : EnemyUnit) -> void:
	current_target = target
	World.level.target_retical.visible = true
	World.level.target_retical.global_position = target.global_position
	World.level.level_camera.jump_to_point(target.global_position)
