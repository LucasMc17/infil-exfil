@tool
## Class for debug elements which ensures that the foldable container begins folded in game, but unfolded in editor.
class_name FoldingInspector
extends FoldableContainer

func _ready() -> void:
	folded = !Engine.is_editor_hint()
