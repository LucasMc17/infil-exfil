## Movement state specifically for player-controlled characters.
class_name PlayerMovementState
extends MovementState

func enter(previous_state, ext) -> void:
	super(previous_state, ext)
	unit.is_moving = true
	Events.skill_disarmed.emit()
	if ext.has('path'):
		full_path = path.duplicate()
		unit.movement_points -= path.size()
	else:
		DebugConsole.error('Must pass PlayerMovementState a path array of points.')
	Level.current_level.movement_system.deactivate()


func exit():
	super()
	unit.finished_moving.emit(unit, true)