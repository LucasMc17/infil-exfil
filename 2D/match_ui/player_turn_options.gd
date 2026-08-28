extends HBoxContainer

func _on_end_turn_button_pressed() -> void:
	if Level.current_level.allow_inputs:
		Events.player_turn_ended.emit()
