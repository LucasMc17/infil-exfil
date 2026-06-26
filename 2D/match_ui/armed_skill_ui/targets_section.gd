class_name TargetsSection
extends VBoxContainer

const TARGET_ICON = preload('./target_icon.tscn')

var current_target : TargetIcon = null
var armed_skill : SingleTargetSkill

@onready var _targets : HBoxContainer = %Targets

func build(skill : SingleTargetSkill) -> void:
	armed_skill = skill
	current_target = null
	for target in skill.potential_targets:
			var target_icon = TARGET_ICON.instantiate()
			target_icon.target = target
			target_icon.target_selected.connect(_on_target_icon_clicked)
			_targets.add_child(target_icon)


func teardown() -> void:
	armed_skill = null
	current_target = null
	World.level.active_unit.clear_target()
	for child in _targets.get_children():
		child.queue_free()


func _on_target_icon_clicked(target_icon : TargetIcon):
	if current_target:
		current_target.button_pressed = false
	if current_target == target_icon:
		current_target = null
	else:
		current_target = target_icon
		World.level.active_unit.draw_target(current_target.target)