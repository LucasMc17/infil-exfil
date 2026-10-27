class_name Sound
extends Resource

## Enum representing a scale of severity of response to different sounds.
enum Severity {
	## The sound will draw the attention of enemy units but will not alarm them. (i.e. footsteps, something falling over, etc.)
	NORMAL,
	## The sound will draw the attention of enemy units but will only alarm them if they have been previously alerted to an enemy presence (i.e. silenced gunshots, grunting)
	SUSPICIOUS,
	## The sound will instantly put enemies who hear it into an alarmed state (i.e. undisguised gunshots, explosions, screams)
	ALARMING
}

## The full distance this sound can travel from the point of origin.
@export var radius := 5.0
# NOTE: This is not implemeted yet and I don't even really like it yet as a design idea. More to come.
## The distance this sound can travel from it's point of origin if there is a piece of geometry in the way.
@export var penetrating_radius := 2.5

## The severity of the sound when heard by enemy units.
@export var severity := Severity.NORMAL
## A one word description of the sound to be used by overhearing units when emitting bark dialog about the sound. Should be all lower case and singular. The dialog system will automatically handle capitalizing and pluralizing as needed.
@export var description := 'sound'
## A list of custom options for dialog to be said in response to this sound. If this array is not empty, then responding units will pick their dialog response from this list instead of the standard [Barks] file.
@export var custom_reaction_lines : Array[String] = []

