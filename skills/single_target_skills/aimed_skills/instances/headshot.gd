class_name Headshot
extends AimedSkill

@export_group('Chance to Hit')
@export var min_chance := 0.1
@export var max_chance := 0.85

var chance := 0.1

func use() -> void:
	super()
	var dice_roll = randf()
	if dice_roll >= chance:
		DebugConsole.log('headshot hits')
	else:
		DebugConsole.log('Headshot misses')
