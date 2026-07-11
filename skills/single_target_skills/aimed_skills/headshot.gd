class_name Headshot
extends AimedSkill

@export_group('Chance to Hit')
@export var min_chance := 0.1
@export var max_chance := 0.85

var chance := 0.1

func arm() -> void:
	super()
	chance = 0.1


func disarm() -> void:
	super()
	chance = 0.1


func use() -> void:
	var dice_roll = randf()
	DebugConsole.log(['dice roll: ', dice_roll, 'odds of hitting: ', 1 - chance])
	if dice_roll >= 1 - chance:
		DebugConsole.log('headshot hits')
	else:
		DebugConsole.log('Headshot misses')
	super()


func retarget(new_target : Unit) -> void:
	super(new_target)
	if new_target:
		var distance = user.global_position.distance_to(new_target.global_position)
		var chance_range = max_chance - min_chance
		var percent_per_meter = chance_range / (effective_range - 1) 
		chance = min_chance + ((effective_range - distance) * percent_per_meter) 
	else:
		chance = 0.1