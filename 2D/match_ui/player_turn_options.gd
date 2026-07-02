extends HBoxContainer

func _on_end_turn_button_pressed() -> void:
	Events.player_turn_ended.emit()
