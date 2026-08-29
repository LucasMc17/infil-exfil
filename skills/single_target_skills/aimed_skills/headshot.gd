class_name Headshot
extends AimedSkill

@export_group('Chance to Hit')
## The minimum chance this skill can have to hit (at the edge of its effective range).
@export_range(0.0, 1.0, 0.01, "suffix:%") var min_chance := 0.1
## The maximum chance this skill cant have to hit (when directly next to the target).
@export_range(0.0, 1.0, 0.01, "suffix:%") var max_chance := 0.85

## The chance to hit, to be recalculated when a target is selected.
var chance := 0.1

func arm() -> void:
	super()
	chance = 0.1


func disarm() -> void:
	super()
	chance = 0.1


func begin_use() -> void:
	user.audio_machine.play_audio('gunshot')
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