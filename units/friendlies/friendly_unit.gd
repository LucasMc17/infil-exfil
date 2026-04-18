@tool
class_name FriendlyUnit
extends Unit

@onready var _visible_zone := %VisibleZone

func reset():
	can_move = true


func check_for_detection():
	_visible_zone.queue_detection_check()