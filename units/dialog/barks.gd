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
	"{plural_sound}!",
	"Oh, shit!",
	"{cap_sound}, move in, move in!",
	"I just heard {article} {sound}!",
	"We've got {plural_sound}, engage!",
	"Enemy Contact!",
	"That what I think it was?"
]

static func get_alarming_sound_line(sound : String) -> String:
	return alarming_sound_lines.pick_random().format(
		{
			"sound": sound,
			"cap_sound": sound.capitalize(), "plural_sound" : sound + "es" if sound[-1] == 's' else sound + 's',
			"article": 'an' if ['a', 'e', 'i', 'o', 'u'].has(sound[0]) else 'a'
		}
	)
