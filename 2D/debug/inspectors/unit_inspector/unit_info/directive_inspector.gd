class_name DirectiveInspector
extends PanelContainer

@onready var _current_directive : DebugKVPair = %CurrentDirective

var decision_director : DecisionDirectorModule

func refresh (new_module : DecisionDirectorModule = null) -> void:
	if new_module:
		decision_director = new_module
	if decision_director:
		_current_directive.value = decision_director.last_directive_name
