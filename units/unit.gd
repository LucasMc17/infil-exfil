@tool
class_name Unit
extends AnimatableBody3D

const SKILL_TARGETING_AREA = preload("res://skills/single_target_skills/skill_targeting_area.tscn")

signal started_moving(unit : Unit)
signal finished_moving(unit : Unit)
signal started_acting(unit : Unit)
signal finished_acting(unit : Unit)
signal forfeited_turn(unit : Unit)

@export var primary_weapon : Weapon

@export var skills : Array[Skill] = []

@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		if is_node_ready():
			global_position = NavigableGridMapV2.convert_grid_to_global_position(tile_position, true)
		if debug_label:
			debug_label.change_param('x', str(round(tile_position.x)))
			debug_label.change_param('y', str(round(tile_position.y)))
			debug_label.change_param('z', str(round(tile_position.z)))

@export var max_movement := 4

@export var max_movement_points := 1:
	get():
		if DebugOptions.unlimited_mp:
			return 100
		return max_movement_points
@export var max_action_points := 1:
	get():
		if DebugOptions.unlimited_ap:
			return 100
		return max_action_points

var potential_moves : Array[Vector3] = []
var movement_points := max_movement_points:
	set(val):
		movement_points = val
		if flag:
			flag.refresh(self)
var action_points := max_action_points:
	set(val):
		action_points = val
		if flag:
			flag.refresh(self)
var is_active : bool:
	get():
		if World.level:
			return World.level.active_unit == self
		else:
			return false

var actual_position : Vector3i:
	get():
		return tile_position as Vector3i
var all_skills : Array[Skill]:
	get():
		var result = skills.duplicate()
		if primary_weapon:
			result.append_array(primary_weapon.skills.duplicate())
		return result
var targeted_skills : Array[SingleTargetSkill]:
	get():
		var result : Array[SingleTargetSkill] = []
		for skill in all_skills:
			if skill is SingleTargetSkill:
				result.append(skill)
		return result
		
@onready var _cell_highlight := %CellHighlight
@onready var flag : UnitFlag = %UnitFlag
@onready var movement_machine : MovementMachine = %MovementMachine
@onready var action_machine : ActionMachine = %ActionMachine
@onready var debug_label : DebugLabel = %DebugLabel
@onready var skill_area_holder : Node3D = %SkillAreaHolder
@onready var seen_zone : SeenZone = %SeenZone

func _ready(): 
	if primary_weapon:
		primary_weapon = primary_weapon.make_unique()
		primary_weapon.initialize(self)
	var temp = skills.duplicate()
	skills = []
	for skill in temp:
		skills.append(skill.make_unique())

	debug_label.change_param('x', str(round(tile_position.x)))
	debug_label.change_param('y', str(round(tile_position.y)))
	debug_label.change_param('z', str(round(tile_position.z)))
	_set_up_skills()

	flag.refresh(self)


func _set_up_skills() -> void:
	for skill : Skill in all_skills:
		skill.user = self
		if skill is SingleTargetSkill:
			var targeting_area = SKILL_TARGETING_AREA.instantiate()
			targeting_area.skill = skill
			targeting_area.area_radius = skill.effective_range
			skill.skill_area = targeting_area
			skill_area_holder.add_child(targeting_area)


# func _refresh_skill_affordability() -> void:
# 	for skill in all_skills:
# 		if skill is SingleTargetSkill:
# 			skill.refresh_targets()


# NOTE: There's a lot more to do here. Right now this is called when the unit is activated, or enters or exits a movmement state. I think there could be a more elegant solution, utilizing signals to determine when the list of available moves should be updated. I am also considering changing the level cell highlighter from the global level to a per unit level, then just swapping its visibility as the unit is activated/deactivated.
func refresh_valid_moves():
	var valid_moves : Array[Vector3] = []
	if World.level and can_move():
		valid_moves = World.level.nav_map.get_all_valid_moves(actual_position, max_movement)
	if World.level and is_active:
		World.level.cell_highlighter.highlighted_cells = valid_moves
	potential_moves = valid_moves


func activate():
	_cell_highlight.visible = true
	flag.refresh(self)
	flag.expand()
	skill_area_holder.visible = true
	refresh_valid_moves()
	# _refresh_skills()
	Events.unit_activated.emit(self)


func deactivate():
	_cell_highlight.visible = false
	flag.collapse()
	skill_area_holder.visible = false


func reset():
	movement_points = max_movement_points
	action_points = max_action_points


# NOTE: I don't like these.
func can_move() -> bool:
	return movement_points > 0 and movement_machine.current_state is NoMovement


func can_act() -> bool:
	return action_points > 0 and action_machine.current_state is NoAction


func forfeit_turn() -> void:
	movement_points = 0
	action_points = 0
	forfeited_turn.emit(self)


func check_for_detection() -> void:
	pass


func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		movement_machine.current_state.transition('NoMovement')
		# _refresh_skills()
		return
	var direction = (path[0] - tile_position).normalized()
	var angle = atan2(-direction.x, -direction.z)
	rotation.y = angle
	tile_position = tile_position.move_toward(path[0], mps * delta)
	if tile_position == path[0]:
		path.pop_front()
		check_for_detection()