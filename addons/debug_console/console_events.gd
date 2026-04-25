@tool
extends Node

## Signal fired when any active instace of [DebugConsole] receives a named command.
signal command_submitted(command_name : String, parameters : Array)

## Global signal to push a new log to all active instances of [DebugConsole].
## [br]Addon users should fire this via the [DebugConsole.log] command, rather than by emitting it directly.
signal message_logged(message : Variant, log_level : int)

## Global signal to push a new error to all active instances of [DebugConsole].
## [br]Addon users should fire this via the [DebugConsole.error] command, rather than by emitting it directly.
signal error_pushed(error_message : Variant)

## Global signal to push a new warning to all active instances of [DebugConsole].
## [br]Addon users should fire this via the [DebugConsole.warn] command, rather than by emitting it directly.
signal warning_pushed(warning_message : Variant)