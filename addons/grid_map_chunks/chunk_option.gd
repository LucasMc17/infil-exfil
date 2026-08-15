@tool
class_name ChunkOption
extends HBoxContainer

signal previewed(chunk : Chunk)
signal loaded(chunk : Chunk)

const SCENE : PackedScene = preload("uid://cwc2ggd4rigaw")

@onready var label : Label = %Label

var chunk : Chunk
var file_name : String = "example_chunk.tres"

static func new_option(c : Chunk, n : String) -> ChunkOption:
	var option : ChunkOption = SCENE.instantiate()
	option.chunk = c
	option.file_name = n
	return option


func _ready() -> void:
	label.text = file_name

func _on_preview_button_pressed() -> void:
	previewed.emit(chunk)

func _on_load_button_pressed() -> void:
	loaded.emit(chunk)
