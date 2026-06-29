extends HBoxContainer

# NOTE: Might be better to use a shortcut here instead of a globally mapped shift + Enter input.
func _on_end_turn_button_pressed() -> void:
	Events.player_turn_ended.emit()
