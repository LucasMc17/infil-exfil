## A directive representing no specific goal. In practice this should not really be used, it's simple a placeholder for debugging until more complicated rules about switching directives are established.
class_name NoDirective
extends Directive

func begin(unit : EnemyUnit) -> void:
	super(unit)	
	if !unit.temp_blocking_path.is_empty():
		respect_nudge()
	else:
		DebugConsole.log("Enemy takes no action")
		acting_unit.forfeit_turn.call_deferred()
		end()


func respect_nudge() -> void:
	var valid_move = Level.current_level.nav_map.probe_for_viable_move(acting_unit.position, acting_unit.movement_points, func(_pos): return true, acting_unit.temp_blocking_path)
	if valid_move:
		acting_unit.move('Walk', { "end_point": valid_move })
	else:
		DebugConsole.log("Enemy can't move out of the way, takes no action")
		acting_unit.forfeit_turn.call_deferred()
		end()


func _on_finished_moving(_unit : Unit):
	super(acting_unit)
	end()
	acting_unit.forfeit_turn()