class_name UnitDirectiveInspector
extends PanelContainer

@onready var _current_directive : DebugKVPair = %CurrentDirective

var decision_director : DecisionDirectorModule

func refresh (new_module : DecisionDirectorModule = null) -> void:
	if new_module:
		decision_director = new_module
	if decision_director:
		if decision_director.current_directive:
			_current_directive.value = decision_director.current_directive.get_script().get_global_name()
		else:
			_current_directive.value = "None"
