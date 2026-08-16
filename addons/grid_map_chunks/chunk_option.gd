@tool
## UI element representing a chunk in the dock for previewing and loading.
class_name ChunkOption
extends HBoxContainer

## Signal when a request is made to preview this chunk.
signal previewed(chunk : Chunk)
## Signal when a request is made to load this chunk.
signal loaded(chunk : Chunk)

## The Packed Scene of this UI element, for instantiating new instances.
const SCENE : PackedScene = preload("uid://cwc2ggd4rigaw")

## The label of this option's file name.
@onready var label : Label = %Label

## The Chunk resource which this UI element represents.
var chunk : Chunk
## The file name of this chunk option.
var file_name : String = "example_chunk.tres"

## Main function for instantiating a new ChunkOption scene with all required parameters prepopulated.
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
