@tool
class_name FriendlyUnit
extends Unit

@onready var _vision_target_holder := %VisionTargets

var vision_targets : Array[VisibilityPoint]:
	get():
		var result : Array[VisibilityPoint]
		for point : VisibilityPoint in _vision_target_holder.get_children():
			result.append(point)
		return result