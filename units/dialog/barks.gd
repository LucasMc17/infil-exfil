## A collection of bark dialog lines for NPCs as well as functions for selecting them at random.
class_name Barks
extends Object

static var normal_sound_lines : Array[String] = [
	"What was that?",
	"Did you hear something?",
	"Thought I heard something...",
	"Did you hear that?",
	"I didn't make that up...",
	"Got a strange sound here.",
	"Hey! Someone there?",
	"What?",
	"Huh...",
	"Anyone there?"
]

static func get_normal_sound_line() -> String:
	return normal_sound_lines.pick_random()

static var alarming_sound_lines : Array[String] = [
	"{cap_sound}! {cap_sound}!",
	"Contact!",
	"I'm hearing {plural_sound} over here!",
	"That sounds like {article} {sound}!",
	"{plural_cap_sound}!",
	"Oh, shit!",
	"{cap_sound}, move in, move in!",
	"I just heard {article} {sound}!",
	"We've got {plural_sound}, engage!",
	"Enemy contact!",
	"That what I think it was?"
]

static func get_alarming_sound_line(sound : String) -> String:
	var plural_sound = sound + "es" if sound[-1] == 's' else sound + 's'
	return alarming_sound_lines.pick_random().format(
		{
			"sound": sound,
			"cap_sound": sound.capitalize(),
			"plural_sound": plural_sound,
			"plural_cap_sound": plural_sound.capitalize(),
			"article": 'an' if ['a', 'e', 'i', 'o', 'u'].has(sound[0]) else 'a'
		}
	)

static var first_contact_line : Array[String] = [
	"Hey!",
	"Hey! Hold it!",
	"Identify yourself!",
	"We've got intruders {prep} {nav_room}!",
	"Intruders spotted {prep} {nav_room}!",
	"We've got intruders!",
	"Intruders {prep} {nav_room}!",
	"Unknown hostiles!",
	"Hey! Who are you!?",
	"Someone's here!",
	"What are you doing here!?",
	"Hey! State your business!",
]

static func get_first_contact_line(nav_zone : NavZone) -> String:
	return first_contact_line.pick_random().format({"nav_room": nav_zone.name, 'prep': nav_zone.preposition})

static var resumed_contact_lines : Array[String] = [
	"Found you!",
	"Intruders reacquired!",
	"Hostiles reacquired!",
	"There, {prep} {nav_room}!",
	"Contact {prep} {nav_room}!",
	"Hostiles spotted {prep} {nav_room}!",
	"They're {prep} {nav_room}!",
	"There they are!",
	"There! Right there!",
	"It's them!",
	"Contact!",
	"Found them!",
	"I've got them!"
]

static func get_resumed_contact_line(nav_zone : NavZone) -> String:
	return resumed_contact_lines.pick_random().format({"nav_room": nav_zone.name, 'prep': nav_zone.preposition})


# When should an enemy speak?
# When moving to an alert phase from any other awareness state, if they are moving because they have themselves spotted an enemy.
# NO, that's wrong. it's more complicated than that
# If that was all there was to it, an enemy who hears an alarming sound would follow it and say nothing when they encounter the enemy.
# But it's not as simple as making them say something when their targeted friendlies list goes from empty to populated either, or else they'd never shut up. They'd speak any time they lost and regained an enemy, and when investigating an alarm point, all units would shout their heads off on finding friendlies. that's no good.

# For now, I think it should work like this: When an enemy's targeted_enemy list goes from empty to filled, they should speak, IF there is no alarm active. The exception is if they are pursuing an enemy and then reacquire them. But we will work on that in a moment.
