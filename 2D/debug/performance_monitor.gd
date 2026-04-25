extends PanelContainer

@onready var _fps_label := %FPS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_fps_label.text = "%.2f" % (1.0 / delta)
