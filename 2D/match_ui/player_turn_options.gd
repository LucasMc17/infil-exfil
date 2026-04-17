extends HBoxContainer

func _on_end_turn_button_pressed() -> void:
	print("END BUTTON CLICKED")
	Events.player_turn_ended.emit()
