@tool
## The base class of all units in the game, both friendly and enemy.
class_name Unit
extends AnimatableBody3D

## Preloaded skill targeting area scene for instantiation at initial load.
const SKILL_TARGETING_AREA = preload("res://skills/single_target_skills/skill_targeting_area.tscn")

## Signal emitted when the unit begins moving along a navigation path.
signal started_moving(unit : Unit)
## Signal emitted when the unit stops moving along a navigation path for any reason.
signal finished_moving(unit : Unit)
## Signal emitted when the unit begins acting (performing a skill).
signal started_acting(unit : Unit)
## Signal emitted when the unit finishes acting (performing a skill).
signal finished_acting(unit : Unit)
## Signal emitted when the unit ends its turn without exhausting all available AP/MP/other possible actions.
signal forfeited_turn(unit : Unit)

@export_group('Capabilities')
## The unit's main weapon.
@export var primary_weapon : Weapon
## The unit's skills, associated with this particular unit as opposed to the weapons they are equipped with.
@export var skills : Array[Skill] = []

@export_group('Position')
## The unit's current position in tile coordinates on the navgrid.
@export var tile_position := Vector3.ZERO:
	set(val):
		tile_position = val
		if is_node_ready():
			global_position = NavigableGridMap.convert_grid_to_global_position(tile_position, true)
		if debug_label:
			debug_label.change_param('x', str(round(tile_position.x)))
			debug_label.change_param('y', str(round(tile_position.y)))
			debug_label.change_param('z', str(round(tile_position.z)))
## The maximum distance this unit can move in one turn.
@export var max_movement := 4

@export_group('Points')
## The maximum movement points for this unit, to which they are restored at the beginning of each new turn.
@export var max_movement_points := 1
## The maximum action points for this unit, to which they are restored at the beginning of each new turn.
@export var max_action_points := 1

## The tile positions that this unit can navigate to.
var potential_moves : Array[Vector3i] = []
## The number of movement points this unit has. Restored to the maximum at the start of a turn.
var movement_points := max_movement_points:
	set(val):
		movement_points = val
		if flag:
			flag.refresh(self)
## The number of action points this unit has. Restored to the maximum at the start of a turn.
var action_points := max_action_points:
	set(val):
		action_points = val
		if flag:
			flag.refresh(self)
## Whether or not this unit is currently the active unit within the level.
var is_active : bool:
	get():
		if World.level:
			return World.level.active_unit == self
		else:
			return false

## The unit's [TilePosition] converted to a Vector3i so that it will reflect a specific tile on the grid.
var actual_position : Vector3i:
	get():
		return tile_position as Vector3i
## The full array of skills available to this unit, including their own, and those associated with their primary weapon.
var all_skills : Array[Skill]:
	get():
		var result = skills.duplicate()
		if primary_weapon:
			result.append_array(primary_weapon.skills.duplicate())
		return result
## All of the [SingleTargetSkill]s from the unit's full array of skills.
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


## Initialize the skills for this unit as an actor within the level.
func _set_up_skills() -> void:
	for skill : Skill in all_skills:
		skill.user = self
		if skill is SingleTargetSkill:
			var targeting_area = SKILL_TARGETING_AREA.instantiate()
			targeting_area.skill = skill
			targeting_area.area_radius = skill.effective_range
			skill.skill_area = targeting_area
			skill_area_holder.add_child(targeting_area)


# NOTE: There's a lot more to do here. Right now this is called when the unit is activated, or enters or exits a movmement state. I think there could be a more elegant solution, utilizing signals to determine when the list of available moves should be updated. I am also considering changing the level cell highlighter from the global level to a per unit level, then just swapping its visibility as the unit is activated/deactivated.
## Update the list of valid moves for this unit based on their maximum move distance and what positions within that range are navigable to.
func refresh_valid_moves():
	var valid_moves : Array[Vector3i] = []
	if World.level and can_move():
		valid_moves = World.level.nav_map._recursively_get_valid_pos_v2(actual_position, max_movement, {}, true, actual_position)
		# valid_moves = World.level.nav_map.get_all_valid_moves(actual_position, max_movement)
	if World.level and is_active:
		World.level.cell_highlighter.highlighted_cells = valid_moves
	potential_moves = valid_moves


## Executed when the unit becomes the active unit within the level.
func activate():
	_cell_highlight.visible = true
	flag.refresh(self)
	flag.expand()
	skill_area_holder.visible = true
	refresh_valid_moves()
	# _refresh_skills()
	Events.unit_activated.emit(self)


## Executed when the unit stops being the active unit within the level.
func deactivate():
	_cell_highlight.visible = false
	flag.collapse()
	skill_area_holder.visible = false
	Events.skill_disarmed.emit()


## Return the unit to a default state, with action and movement points reset.
func reset():
	movement_points = 100 if DebugOptions.unlimited_mp else max_movement_points
	action_points = 100 if DebugOptions.unlimited_ap else max_action_points


# NOTE: I don't like these.
## Returns true if the unit is still capable of moving this turn.
func can_move() -> bool:
	return movement_points > 0 and movement_machine.current_state is NoMovement


## Returns true if the unit is still capable of acting this turn.
func can_act() -> bool:
	return action_points > 0 and action_machine.current_state is NoAction


## Mark this unit as finished acting and set their MP/AP to 0.
func forfeit_turn() -> void:
	movement_points = 0
	action_points = 0
	forfeited_turn.emit(self)
## Function for updating detected units, either by checking if this unit is being detected or if it is detecting any other units.
func check_for_detection() -> void:
	pass


## Move along a navigable path towards a destination point.
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