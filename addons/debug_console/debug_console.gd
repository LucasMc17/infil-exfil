@tool
class_name DebugConsole
extends PanelContainer
## Debug Console, containing functions for logging, printing warnings and errors, and instantiating logic for all commands.

## Object representing a print command to the console. Contains the log records message and log level.
class LogObject:
	var message : Variant
	var log_level : int
	var is_warning : bool
	var is_error : bool

	func _init(m : Variant, ll : int, w := false, e := false):
		message = m
		log_level = ll
		is_warning = w
		is_error = e

enum LogLevel {
	NONE,
	ONLY_ARBITRARY,
	LOW,
	MEDIUM,
	HIGH
}

const ECHO_COMMAND := preload('./echo_command.tres')
const HELP_COMMAND := preload('./help_command.tres')
const CLEAR_COMMAND := preload('./clear_command.tres')

## Static array containing all past log commands in order received. Used to initialize a console with past messages logged, if [should_print_queued_on_ready] is true.
static var past_logs : Array[LogObject] = []

## Array representing the history of commands issued to the console by the user.
var _command_history := []
## A pointer indicating position within the `_command_history` array when tabbing through past commands via the arrow keys.
var _history_pointer
## Dictionary containing all the commands this console has access to, by their names.
var _command_dict : Dictionary[String, CommandConfig] = {}

# Nodes to be instantiated on ready.
var _vbox : VBoxContainer
var _history : RichTextLabel
var _command_line : LineEdit

## An array of commands which the [DebugConsole] should recognize. Comes preloaded with [echo] [help] and [clear].
## [br] To extend this list, create a new [CommandConfig] resource instance. Then connect to the global signal [ConsoleEvents.command_submitted] anywhere in your code.
## The first parameter of this signal is the name of the incoming command while the second parameter is an array of parameters/flags passed with it. You can use this signal
## to listen for your custom command and trigger custom behavior against it anywhere you would like in your code.
@export var commands : Array[CommandConfig] = [
	ECHO_COMMAND,
	HELP_COMMAND,
	CLEAR_COMMAND
]
## The log level of the console. When incoming logs are received by the console, it will only print them if the messages' log levels are equal to or less than the console's log level.
## [br] For example, if a log is pushed with a level of 4 (HIGH), a console with a log_level of 1 (ONLY_ARBITRARY) will not print it.
@export var console_log_level : LogLevel = LogLevel.ONLY_ARBITRARY
## Determines whether the console should print all messages which were queued before it finished readying. This is so that messages pushed for logging in other scenes [_ready] functions
## will not be missed by this console. Leave this as [true] if this [DebugConsole] will be present immediately in the scene tree. Set to false if the [DebugConsole] will be triggered to instantiate
## through code later on.
@export var should_print_queued_on_ready := true

## Static function to push a print command to all active instaces of this [DebugConsole]
static func log(message : Variant, log_level := 1) -> void:
	ConsoleEvents.message_logged.emit(message, log_level)
	past_logs.append(LogObject.new(message, log_level))


## Static function to push a warning to all active instaces of this [DebugConsole]
static func warn(message : Variant) -> void:
	ConsoleEvents.warning_pushed.emit(message)
	past_logs.append(LogObject.new(message, -1, true))


## Static function to push an error to all active instaces of this [DebugConsole]
static func error(message : Variant) -> void:
	ConsoleEvents.error_pushed.emit(message)
	past_logs.append(LogObject.new(message, -1, false, true))


func _ready() -> void:
	ConsoleEvents.command_submitted.connect(_on_command_submitted)
	ConsoleEvents.message_logged.connect(_handle_log)
	ConsoleEvents.warning_pushed.connect(_warn)
	ConsoleEvents.error_pushed.connect(_error)

	for command : CommandConfig in commands:
		_command_dict[command.name] = command
	_vbox = VBoxContainer.new()
	add_child(_vbox)

	_history = RichTextLabel.new()
	_history.bbcode_enabled = true
	_history.scroll_following = true
	_history.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
	_history.size_flags_vertical = Control.SizeFlags.SIZE_EXPAND_FILL
	_vbox.add_child(_history)

	_command_line = LineEdit.new()
	_command_line.keep_editing_on_text_submit = true
	_command_line.text_submitted.connect(_on_command_line_text_submitted)
	_vbox.add_child(_command_line)

	if should_print_queued_on_ready:
		for log in past_logs:
			if log.is_error:
				_error(log.message)
			elif log.is_warning:
				_warn(log.message)
			else:
				_handle_log(log.message, log.log_level)


func _gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_command_line.grab_focus()


func _input(_event) -> void:
	if _command_line.has_focus() and Input.is_action_just_pressed("ui_up"):
		if _history_pointer == 0:
			return
		if _history_pointer != null and _history_pointer > 0:
			_get_from_history(_history_pointer - 1)
			return
		elif !_history_pointer and _command_history.size() > 0:
			_get_from_history(_command_history.size() - 1)
			return
	elif _command_line.has_focus() and Input.is_action_just_pressed("ui_down"):
		if _history_pointer != null and _history_pointer < _command_history.size() - 1:
			_get_from_history(_history_pointer + 1)
			return

## Prints a single data point or a sequence as an array to the terminal.
func _print(message : Variant, color : Color = Color.WHITE) -> void:
		# NOTE: this could get much more in depth but this will do for now
		if message is Array:
			for i in message.size():
				var element = message[i]
				var prefix = ''
				if i == 0:
					prefix = '> '
				_history.text += '\n[color=' + color.to_html(false) + ']' + prefix + str(element) + '[/color]'
				print(element)
		else:
			_history.text += '\n[color=' + color.to_html(false) + ']>' + str(message) + '[/color]'
			print(message)


## Wrapper function of _print which also pushes a warning to the godot terminal AND the in game console.
func _warn(message) -> void:
	push_warning(message)
	_print(message, Color.YELLOW)


## Wrapper function of _print which also pushes an error to the godot terminal AND the in game console.
func _error(message) -> void:
	push_error(message)
	_print(message, Color.RED)


## Primary function for initiating a command from the terminal, or reporting an error if no matching command is found.
func _run(full_command : String) -> void:
	var params = Array(full_command.split(' '))
	var command_name = params.pop_front()
	if _command_dict.has(command_name):
		ConsoleEvents.command_submitted.emit(command_name, params)
	else:
		_error("ERROR: Command '" + command_name + "' Not found. Run 'help' for a list of commands")

## Utilizes the `_history_pointer` to find a command from the `_command_history`.
func _get_from_history(pointer : int) -> void:
	_history_pointer = pointer
	_command_line.text = _command_history[pointer]
	_command_line.call_deferred("set_caret_column", 1000)


func _on_command_line_text_submitted(new_text) -> void:
	_command_history.append(new_text)
	_history_pointer = null
	_run(new_text)
	_command_line.text = ''


func _on_history_gui_input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_command_line.call_deferred("grab_focus")


func _on_command_submitted(command_name : String, parameters: Array) -> void:
	if command_name == "echo":
		_print(' '.join(parameters))
	elif command_name == "help":
		_print(_command_dict.values().map(func (command): return command.to_string()))
	elif command_name == "clear":
		_history.text = ''


func _handle_log(message : Variant, log_level : int) -> void:
	if console_log_level == LogLevel.NONE:
		return
	log_level = clamp(log_level, 1, 4)
	if console_log_level as int >= log_level:
		_print(message)
		if log_level == 1:
			_warn("WARNING: Arbitrary log left in code")