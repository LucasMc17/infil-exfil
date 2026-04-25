@tool
class_name DebugLabel
extends Sprite3D
## Debug Label displaying information about an actor in the scene in 3d space. [br]
## Is visible through walls.

var _viewport : SubViewport

var _label : Label

## The text of the label. Designed to be formatted based on the parameters in the `params` object below and so can include variable names like `{this}`.
@export_multiline var _text := "Example text:\nLOREM IPSUM\nFOO BAR":
	set(val):
		_text = val
		if Engine.is_editor_hint():
			format_text()
## Whether to render the label with a transparent background or not.
@export var _transparent_background := true:
	set(val):
		_transparent_background = val
		if Engine.is_editor_hint():
			_viewport.transparent_bg = _transparent_background
## The alignment of the label text within the subviewport displayed by the 3D sprite.
@export var _text_alignment := HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT:
	set(val):
		_text_alignment = val
		if Engine.is_editor_hint():
			_label.horizontal_alignment = _text_alignment

## The parameters actively in use in the label formatting.
var _params := {}

func _ready():
	# Create the viewport
	_viewport = SubViewport.new()
	_viewport.transparent_bg = _transparent_background
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	pixel_size = 0.005
	visibility_range_end = 20.0
	add_child(_viewport)
	
	# Create the label within the viewport
	_label = Label.new()
	_label.horizontal_alignment = _text_alignment
	_label.resized.connect(_on_label_resized)
	_viewport.add_child(_label)
	texture = _viewport.get_texture()

	# Finally, display the most up to date text within the label
	format_text()


## Update a parameter in the `_params` object and reformat the label.[br]
## This is the main function which should be used to update the label from external contexts.
func change_param(param : String, new_value : String) -> void:
	_params[param] = new_value
	format_text()


## Format the text of the label with the params provided, and resize the [DebugLabel] as needed.
func format_text():
	if _viewport and _label:
		var formatted = _text.format(_params)
		_label.text = formatted


func _on_label_resized():
	if _viewport:
		_viewport.set_deferred('size', _label.size + Vector2(10, 10))