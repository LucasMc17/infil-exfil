extends HBoxContainer

func _on_end_turn_button_pressed() -> void:
	if World.level.allow_inputs:
		Events.player_turn_ended.emit()
