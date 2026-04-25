@tool
class_name CommandConfig
extends Resource
## Name of the command.
@export var name : String
## Description of the command and its utility.
@export var description : String
## Expected parameters of the command, and a brief description of each.
@export var parameters : String
## Examples of how to use the command.
@export var examples : Array[String]

func to_string() -> String:
	return name + "\n-- " + description + '\n-- Parameters: ' + parameters + '\n-- e.g. ' + ', '.join(examples) + '\n'

