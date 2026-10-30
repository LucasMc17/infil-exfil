extends HBoxContainer

func _on_end_turn_button_pressed() -> void:
	if Level.current.allow_inputs:
		Events.player_turn_ended.emit()
