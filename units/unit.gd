@tool
## The base class of all units in the game, both friendly and enemy.
class_name Unit
extends AnimatableBody3D

## Enum representing all the possible statuses for a unit, from alive and acting to dead and out of play.
enum Status {
	## Alive, aware and responsive.
	ALIVE,
	## Alive, but stunned and unable to move or act for the moment.
	STUNNED,
	## Alive, but held hostage by another [Unit].
	CAPTIVE,
	## Alive, but unconscious and unable to move or act until awoken by another unit. Does not block space.
	UNCONSCIOUS,
	## Dead and permanently unable to move or act.
	DEAD
}

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

@export_group('Status')
## The unit's maximum health value.
@export var max_health_points := 5
## The unit's status, either alive, unconscious, stunned or dead.
@export var unit_status := Status.ALIVE

@export_group('Capabilities')
## The unit's main weapon.
@export var primary_weapon : Weapon
## The unit's skills, associated with this particular unit as opposed to the weapons they are equipped with.
# @export var skills : Array[Skill] = []

@export_group('Points')
## The maximum movement points for this unit, to which they are restored at the beginning of each new turn.
@export var max_movement_points := 5
## The maximum action points for this unit, to which they are restored at the beginning of each new turn.
@export var max_action_points := 1

## The number of health points this unit has.
var health_points := max_health_points:
	set(val):
		if val < 0:
			health_points = 0
		else:
			health_points = val
		if flag:
			flag.refresh(self)
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
		if Level.current_level:
			return Level.current_level.active_unit == self
		else:
			return false
## Whether or not this unit is in the middle of using a skill.
var is_using_skill : bool:
	get():
		return !!skill_machine.current_skill
## Whether or not this unit is moving to a point.
var is_moving := false

## The unit's position in terms of the NavigableGridMap's coordinate system.
var board_position : Vector3i
## The full array of skills available to this unit, including their own, and those associated with their primary weapon.
var all_skills : Array[Skill]:
	get():
		var result : Array[Skill] = []
		var skills = skill_machine.get_children()
		for skill in skills:
			if skill is Skill:
				result.append(skill)
		return result
## All of the [AimedSkill]s from the unit's full array of skills.
var aimed_skills : Array[AimedSkill]:
	get():
		var result : Array[AimedSkill] = []
		for skill in all_skills:
			if skill is AimedSkill:
				result.append(skill)
		return result

## The unit this unit is currently holding captive, if one exists.
var captive : Unit
## The unit that is currently holding this unit as a captive, if one exists.
var captor : Unit
	
@onready var _cell_highlight := %CellHighlight
@onready var flag : UnitFlag = %UnitFlag
@onready var movement_machine : MovementMachine = %MovementMachine
@onready var debug_label : DebugLabel = %DebugLabel
@onready var skill_machine : SkillMachine = %SkillMachine
@onready var seen_zone : SeenZone = %SeenZone
@onready var _mesh_instance : MeshInstance3D = %MeshInstance3D
@onready var _hostage_marker : Marker3D = %HostageMarker
@onready var _collision : CollisionShape3D = %CollisionShape3D
@onready var audio_machine : StaticAudioMachine = %StaticAudioMachine

func _ready():
	board_position = NavigableGridMap.convert_global_to_grid_position(Vector3i(position))
	if !Engine.is_editor_hint():
		Events.skill_disarmed.connect(refresh_valid_moves)
		if primary_weapon:
			primary_weapon = primary_weapon.make_unique()
			primary_weapon.initialize(self)

		debug_label.change_param('x', str(round(position.x)))
		debug_label.change_param('y', str(round(position.y)))
		debug_label.change_param('z', str(round(position.z)))

		flag.refresh(self)


## Update the list of valid moves for this unit based on their maximum move distance and what positions within that range are navigable to.
func refresh_valid_moves() -> void:
	if Level.current_level and can_move() and is_active:
		Level.current_level.movement_system.activate(self)


## Executed when the unit becomes the active unit within the level.
func activate():
	_cell_highlight.visible = true
	flag.refresh(self)
	flag.expand()
	skill_machine.visible = true
	refresh_valid_moves()
	# _refresh_skills()
	Events.unit_activated.emit(self)
	Events.refresh_unit_skills.emit()


## Executed when the unit stops being the active unit within the level.
func deactivate():
	_cell_highlight.visible = false
	flag.collapse()
	skill_machine.visible = false
	# TODO: Make this a signal
	Level.current_level.movement_system.deactivate()
	Events.unit_deactivated.emit(self)
	if Level.current_level.armed_skill:
		Events.skill_disarmed.emit()


## Return the unit to a default state, with action and movement points reset.
func reset():
	movement_points = 100 if DebugOptions.unlimited_mp else max_movement_points
	action_points = 100 if DebugOptions.unlimited_ap else max_action_points


## Take appropriate amount of damage and kill the unit if health drops to zero.
func damage(amount : int) -> void:
	health_points -= amount
	if health_points < 1:
		die()


## Kill the unit and remove them from play.
func die() -> void:
	DebugConsole.log("Unit " + name + " dies.", 2)
	Events.unit_disabled.emit(self)
	Events.unit_died.emit(self)
	_collision.disabled = true
	_mesh_instance.position.y = 0.0
	unit_status = Status.DEAD


## Knock out the unit and remove them from play.
func lose_consciousness() -> void:
	DebugConsole.log("Unit " + name + " loses consciousness.", 2)
	Events.unit_disabled.emit(self)
	Events.unit_lost_consciousness.emit(self)
	_collision.disabled = true
	_mesh_instance.position.y = 0.0
	unit_status = Status.UNCONSCIOUS


## Bring the unit back from unconsciousness.
func regain_consciousness() -> void:
	DebugConsole.log("Unit " + name + " regains consciousness.", 2)
	_collision.disabled = false
	_mesh_instance.position.y = 1.0
	unit_status = Status.ALIVE


## Runs when the unit grabs another unit as a captive.
func take_captive(captured : Unit) -> void:
	captive = captured
	captive.captor = self
	captive.unit_status = Status.CAPTIVE
	Events.unit_disabled.emit(captive)
	Events.unit_taken_captive.emit(captive)
	captive.position = _hostage_marker.global_position
	captive.board_position = board_position
	captive.rotation.y = rotation.y
	if captive is EnemyUnit:
		captive.awareness.alarm(self, true)


## Runs when the unit releases their captive. Takes in a boolean representing whether or not the captive was killed before being released.
func release_captive(was_incapacitated := false, was_killed := false) -> void:
	if captive:
		captive.position = position
		captive.captor = null
		if was_incapacitated:
			if was_killed:
				captive.die()
			else:
				captive.lose_consciousness()
		else:
			captive.unit_status = Status.ALIVE
		captive = null


## Returns true if the unit is incapacitated (dead or unconscious).
func is_incapacitated() -> bool:
	return unit_status == Status.UNCONSCIOUS or unit_status == Status.DEAD or unit_status == Status.CAPTIVE


## Returns true if the unit is still capable of moving this turn.
func can_move() -> bool:
	return unit_status == Status.ALIVE and movement_points > 0 and movement_machine.current_state is NoMovement


## Returns true if the unit is still capable of acting this turn.
func can_act() -> bool:
	return unit_status == Status.ALIVE and action_points > 0


## Mark this unit as finished acting and set their MP/AP to 0.
func forfeit_turn() -> void:
	movement_points = 0
	action_points = 0
	forfeited_turn.emit(self)

	
## Function for updating detected units, either by checking if this unit is being detected or if it is detecting any other units.
func check_for_detection() -> void:
	pass


# TODO: Enemy units should extend this to accidentally bump into unseen friendly units rather than blindly pathing around them. I think this will actually require a change to the resolve blocked spaces fun, wherein when an enemy is active, spaces of unseen friendlies are given a normal weight. This won't actually allow them to path through them, but will allow them to try. they should also turn to face a point in the path even if blocked by something in it.
# TODO: There should also be a more elegant turning solution that only updates rotation.y when required, not every frame.
## Move along a navigable path towards a destination point.
func follow_path(delta : float, path : Array, mps := 1.0) -> void:
	if path.is_empty():
		movement_machine.current_state.transition('NoMovement')
		return
	var next_board_pos = path[0]
	var next_global_pos = NavigableGridMap.convert_grid_to_global_position(next_board_pos)
	var direction = (next_global_pos - position).normalized()
	var angle = atan2(-direction.x, -direction.z)
	if rotation.y != angle:
		rotation.y = angle
	position = position.move_toward(next_global_pos, mps * delta)
	if position == next_global_pos:
		board_position = next_board_pos
		path.pop_front()
		check_for_detection()
	if captive:
		captive.position = _hostage_marker.global_position
		captive.board_position = board_position
		captive.rotation.y = angle