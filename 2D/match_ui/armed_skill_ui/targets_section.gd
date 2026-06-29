## The slice of the [ArmedSkillUI] which represents the potential targets for the skill. Only relevant for skills which target a single unit.
class_name TargetsSection
extends VBoxContainer

## [TargetIcon] scene for instantiation.
const TARGET_ICON = preload('./target_icon.tscn')

## The particular [TargetIcon] instance which is currently selected, if one exists.
var selected_target_icon : TargetIcon = null

@onready var _targets : HBoxContainer = %Targets

## Creates the [TargetIcon] scenes in the scene tree and connects their output signals.
func build(skill : SingleTargetSkill) -> void:
	Events.target_cleared.emit()
	selected_target_icon = null
	var index := 1
	for target in skill.potential_targets:
			var target_icon = TARGET_ICON.instantiate()
			target_icon.build(target, index)
			target_icon.target_selected.connect(_on_target_icon_clicked)
			_targets.add_child(target_icon)
			index += 1


## Removes the targets from the UI, fully resetting the scene.
func teardown() -> void:
	Events.target_cleared.emit()
	selected_target_icon = null
	for child in _targets.get_children():
		child.queue_free()


func _on_target_icon_clicked(target_icon : TargetIcon):
	if selected_target_icon:
		selected_target_icon.button_pressed = false
	if selected_target_icon == target_icon:
		selected_target_icon = null
		Events.target_cleared.emit()
	else:
		selected_target_icon = target_icon
		Events.target_selected.emit(World.level.active_unit, target_icon.target)