@tool
## The UI of the dock which this extension uses to handle saving, loading and previewing map chunks.
class_name MapChunkDock
extends Control

@onready var name_edit : LineEdit = %FileNameEdit
@onready var _option_holder : VBoxContainer = %OptionHolder
@onready var _save_button : Button = %SaveButton
@onready var _chunk_picker : VBoxContainer = %ChunkPicker
@onready var _preview_positioner : PreviewPositioner = %PreviewPositioner

var chunk_ops : ChunkOperator

## The currently inputted file name to be used when saving new chunks through the UI.
var file_name : String:
	get():
		return name_edit.text

func _ready() -> void:
	chunk_ops = ChunkOperator.new()
	visibility_changed.connect(_on_visibility_changed)
	_save_button.pressed.connect(_on_save_button_pressed)

	_preview_positioner.cancel_button.pressed.connect(_cancel_chunk_load)
	_preview_positioner.confirm_button.pressed.connect(_confirm_chunk_load)

	_preview_positioner.z_up_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(0, 0, 1)))
	_preview_positioner.z_down_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(0, 0, -1)))
	_preview_positioner.x_up_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(1, 0, 0)))
	_preview_positioner.x_down_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(-1, 0, 0)))
	
	_preview_positioner.y_up_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(0, 1, 0)))
	_preview_positioner.y_down_button.pressed.connect(chunk_ops.chunk_loader.translate_preview.bind(Vector3i(0, -1, 0)))

	_preview_positioner.rotate_r_button.pressed.connect(chunk_ops.chunk_loader.rotate_preview.bind(true))
	_preview_positioner.rotate_l_button.pressed.connect(chunk_ops.chunk_loader.rotate_preview.bind(false))


func _on_visibility_changed() -> void:
	_refresh_chunks()
	_cancel_chunk_load()


## Forces a refresh of the list of available saved chunks. Happens automatically at key points, but is also triggered by the reset button, in the event of a desync between the UI and the project file structure.
func _refresh_chunks() -> void:
	for child : ChunkOption in _option_holder.get_children():
		# child.previewed.disconnect(_on_preview_button_pressed)
		child.loaded.disconnect(_on_load_button_pressed)
		child.queue_free()
	var dir = DirAccess.open(chunk_ops.SAVED_CHUNKS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var chunk : Chunk = load(chunk_ops.SAVED_CHUNKS_PATH + file_name) as Chunk
				var option_scene = ChunkOption.new_option(chunk, file_name)
				# option_scene.previewed.connect(_on_preview_button_pressed)
				option_scene.loaded.connect(_on_load_button_pressed)
				_option_holder.add_child(option_scene)
			file_name = dir.get_next()
	else:
		print("COULD NOT FIND DIRECTORY")


## Save a selected chunk to the file system, provided a selection is currently present and a valid file name is inputted in the line edit.
func _on_save_button_pressed() -> void:
	if chunk_ops.attempt_chunk_save(file_name):
		print("CHUNK SAVED")
		_refresh_chunks()
	else:
		print("FAILED TO SAVE")


## Load a Chunk resource via the ChunkLoader and reconstruct it in the GridMap, at the current selection's root position.
func _on_load_button_pressed(chunk : Chunk) -> void:
	if chunk_ops.attempt_chunk_preview(chunk):
		print("CHUNK PREVIEW LOADED")
		_toggle_preview_mode(true)
	else:
		print("CHUNK PREVIEW FAILED")


## Switches the UI to preview translation mode when a preview is loaded into the preview layer.
func _toggle_preview_mode(on : bool) -> void:
	_chunk_picker.visible = !on
	_preview_positioner.visible = on


## Cancels a loaded preview and returns to the chunk list menu.
func _cancel_chunk_load() -> void:
	chunk_ops.cancel_load()
	_toggle_preview_mode(false)


## Merges a previewed chunk into the grid map and returns to the chunk list menu.
func _confirm_chunk_load() -> void:
	chunk_ops.attempt_chunk_load()
	_toggle_preview_mode(false)
