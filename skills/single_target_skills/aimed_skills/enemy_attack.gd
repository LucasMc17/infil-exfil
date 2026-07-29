## A basic enemy attack skill, not meant to be used by the player.
extends AimedSkill

const CHANCE := 0.4

func begin_use() -> void:
	if Utilities.dice_roll(CHANCE):
		DebugConsole.log('Enemy attack hits.')
	else:
		DebugConsole.log('Enemy attack misses.')
	super()