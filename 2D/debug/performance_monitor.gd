extends PanelContainer

@onready var _fps_label := %FPS

func _process(delta):
	_fps_label.text = "%.2f" % (Engine.time_scale / delta)
