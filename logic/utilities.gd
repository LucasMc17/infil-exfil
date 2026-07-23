## Reusable functions throughout the project.
class_name Utilities
extends Object

## Takes in a float between 0 and 1, representing the odds of winning the dice roll where 1 is a sure thing, and 0 is impossible. Generates a second float between 0 and 1 randomly and returns true if that second number is greater than or equal to 1 minus the odds passed in at the beginning.
static func dice_roll(odds := 0.5) -> bool:
	var roll := randf()
	DebugConsole.log('Rolled ' + str(roll) + ', and need at least ' + str(1 - odds) + ' to hit.', 2)
	return roll >= 1 - odds


## Linearly converts a distance in meters into a score from 0.0 to 1.0 representing how close that distance is considered to be to the target position. As the name implies, this is most useful for determining a unit's chance to hit with a skill, given a certain distance from the target. The [distance] and [max_distance] parameters are required, but the rest are optional:[br]
## [min_distance] defaults to 0.0. If provided, will consider a minimum distance at which point the skill will return the maximum chance to hit. Using this function on a distance shorter than this [min_distance] will instantly return the [max_chance] to hit.[br]
## [max_chance] defaults to 1.0. If provided, will determine the maximum chance for this skill to hit, which the result of this function cannot exceed.[br]
## [min_chance] defaults to 0.0. If provided, will determine the minimum chance for this skill to hit, which the result of this function cannot go below.
static func convert_range_to_odds(distance : float, max_distance : float, min_distance := 0.0, max_chance := 1.0, min_chance := 0.0) -> float:
	if distance <= min_distance:
		return max_chance
	if distance >= max_distance:
		return min_chance
	var chance_range := max_chance - min_chance
	var percent_per_meter := chance_range / (max_distance - min_distance)
	return min_chance + ((max_distance - distance) * percent_per_meter)


# FEATURE WISHLIST
# - Hostile units should attempt to take captives under certain conditions. each unit should start with a will_take_captives boolean set to true. This is set to false when the unit is shot at by a friendly unit, sees one move after they have given warning to freeze, when hearing a gunshot, when encountering another enemy unit with this already set to false, or when a unit with this already set to false reaches the alarm. When encountering units, captive takers should immediately say freeze, then on their next turn, the first one should run for the alarm, no dice roll needed. The rest should begin moving in to take captives, and when all known friendlies are detained, begin moving them to holding cells. The regular combat flow should happen only when the captives boolean is set to false.
# Path markers and room naming for maps. The game maps should have points highlighted to indicate the flow of the space. Units pursuing sighted friendlies can reference this information to determine which way they may have gone and pursue them a reasonable distance. This sounds complicated but I think a very simple version of it can be accomplished. Relatedly, we should be able to mark certain zones within maps, and give them names. This will allow the enemy units to refer to them by name when reporting enemy locations, and also allow them to path to specific rooms for specific tasks, such as moving detained units to holding cells.