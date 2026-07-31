extends PanelContainer

@onready var _confirm_button : Button = %ConfirmButton
@onready var _cancel_button : Button = %CancelButton

func _ready() -> void:
	Events.planned_path_cleared.connect(_on_planned_path_cleared)
	Events.waymarker_placed.connect(_on_waymarker_placed)


func _on_waymarker_placed() -> void:
	_confirm_button.disabled = false
	_cancel_button.disabled = false
	visible = true


func _on_planned_path_cleared() -> void:
	_confirm_button.disabled = true
	_cancel_button.disabled = true
	visible = false


func _on_confirm_button_pressed() -> void:
	# TODO: There's a case to be made that a lot more of the movement system should operate on global signals.
	if World.level.allow_inputs:
		World.level.active_unit.movement_machine.current_state.transition('Sneak', { "path": World.level.movement_system.path })
		World.level.movement_system.wipe_planned_path()


func _on_cancel_button_pressed() -> void:
	if World.level.allow_inputs:
		World.level.movement_system.wipe_planned_path()
		World.level.movement_system.activate(World.level.active_unit)
