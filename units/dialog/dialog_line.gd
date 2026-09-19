## Dialog box for speaking unit in 3D space. Removes itself after a period of time.
class_name DialogLine
extends Label


@onready var _still_timer : Timer = %StillTimer
@onready var _fade_timer : Timer = %FadeTimer

var target_unit : Unit
var fading := false
var still_time := 3.0
var fade_time := 3.0
var half_size := 0.0

static func new_line(unit : Unit, message : String, still := 3.0, fade := 3.0) -> DialogLine:
	var scene : DialogLine = load("uid://bnppa3rohh7g3").instantiate()
	scene.text = message
	scene.still_time = still
	scene.fade_time = fade
	scene.target_unit = unit
	return scene


func _ready() -> void:
	_still_timer.start()
	half_size = size.x / 2


func _process(delta: float) -> void:
	var camera := Level.current_level.level_camera.camera
	if camera and target_unit:
		var target_pos = target_unit.global_position
		if camera.is_position_behind(target_pos):
			hide()
			return
		show()
		var screen_pos : Vector2 = camera.unproject_position(target_pos)
		screen_pos.x -= half_size
		global_position = screen_pos
		
	if fading:
		offset_transform_position.y += (delta / fade_time) * -20.0
		modulate.a -= (delta / fade_time)


func _on_still_timer_timeout() -> void:
	fading = true
	_fade_timer.start()


func _on_fade_timer_timeout() -> void:
	queue_free()
