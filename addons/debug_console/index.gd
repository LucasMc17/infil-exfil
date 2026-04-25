@tool
extends EditorPlugin

const DEBUG_CONSOLE = preload("./debug_console.gd")
const COMMAND_CONFIG = preload("./command_config.gd")

func _enable_plugin() -> void:
	add_autoload_singleton('ConsoleEvents', "./console_events.gd")
	add_custom_type("DebugConsole", "PanelContainer", DEBUG_CONSOLE, null)
	add_custom_type("CommandConfig", "Resource", COMMAND_CONFIG, null)


func _disable_plugin() -> void:
	remove_custom_type("DebugConsole")
	remove_custom_type("CommandConfig")
	remove_autoload_singleton('ConsoleEvents')