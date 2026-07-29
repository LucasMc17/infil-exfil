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


func begin_use() -> void:
	if Utilities.dice_roll(chance):
		DebugConsole.log('headshot hits')
		target.die()
	else:
		DebugConsole.log('headshot misses')
	super()


func retarget(new_target : Unit) -> void:
	super(new_target)
	if new_target:
		var distance = user.position.distance_to(new_target.position)
		chance = Utilities.convert_range_to_odds(distance, effective_range, 1, max_chance, min_chance)
	else:
		chance = 0.1