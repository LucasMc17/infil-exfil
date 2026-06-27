class_name TargetsSection
extends VBoxContainer

const TARGET_ICON = preload('./target_icon.tscn')

var selected_target_icon : TargetIcon = null

@onready var _targets : HBoxContainer = %Targets

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


func teardown() -> void:
	Events.target_cleared.emit()
	selected_target_icon = null
	World.level.active_unit.clear_target()
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