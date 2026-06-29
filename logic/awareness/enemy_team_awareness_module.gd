## Logic module representing the enemy's awareness of the intruding friendlies. Used at the level of the entire enemy team, rather than a single unit.
## [br]In short, this represents the shared knowledge of the enemies. Individual enemies will have their own logic modules representing their individual knowledge. This separation allows for one enemy unit to be aware of a number of friendly units, without the entire enemy team becoming aware. If this enemy unit is neutralized before raising an alarm, the knowledge will not be passed onto the rest of the enemy force. Conversely, if they do raise an alarm, the entire enemy team will have their general knowledge of the friendly presence elevated to match the number this enemy has observed.
class_name EnemyTeamAwarenessModule
extends Resource

# General notes:
	# Enemies are (for now) unable to tell friendlies apart. IE if they see one, lose track, then later see a different one, they will still believe there is only one intruder.
	# The only way to decrease the eenmy's current known palyer count is for them to believe they have observed a friendly unit dying, whether they are correct or not.
	# Enemies will usually begin in an unalarmed, unalerted state. Once an alarm is raised, even after losing line of sight, they will stay on alert indefinitely.
	# Once the enemy is alerted (not alarmed) they will only return to an unalerted state if their known friendly count drops to 0. They will never let their guard down until they believe the threat is passed.

	# Some more detailed flows:
		# An enemy coming across another dead enemy will raise an alarm. Enemies will not drop guard if no friendlies have been spotted. They will only drop guard once they have spotted and beieved they ahve killed friendlies.
		# The exception is if they have already found and believe they have killed friendlies. Then they will drop guard after the alert, assuming their comrade was dropped by the friendlies they already dealt with.
		# An enemy coming across a dead friendly will raise an alarm, however unlike the above if no active friendlies have been spotted, they will drop guard after the alarm
		# When an enemy sees a friendly, they will be able to distinguish friendlies until they lose their alerted status. When they call in an alarm, the known friendly count will jump to the number of distinct friendlies they saw / have seen while alerted.
		# Once an alarm is active, the game will continuously check for the most distinct friendlies any one enemy unit has seen and update the known_friendly_count when it climbs higher than the value already stored there.
		# In short, while alarmed (and therefore in combat or running for the alarm), enemies are smart enough to distinguish friendlies and count them. Between alarms (even if still on guard), the enemy will remember how many enemies they saw but lose the ability to distinguish them next time they see them, and start countng from 0 again, even if seeing friendlies theyve never seen before.
		# One more small note: Will enemies within earshot of enemies who spot friendlies have their known friendly count increase to match? Possibly. Could have a voice line like "Two hostiles spotted" or some such.

## Whether an alarm is acively raised.
var alarm_active := false
## The alarm which the was tripped. Responding enemies will head to its location, but will change course if they hear combat.
var alarm
## Whether the enemy has encountered friendlies, regardless of how it turned out. Once set to true, does not return to false.
var encountered_friendlies := false
## The number of friendly units which the enemies are aware of.
var known_friendly_count := 0:
	set(val):
		if val > known_friendly_count:
			known_friendly_count = val

# var targeted_friendlies : Array[FriendlyUnit] = []
# var targeted_friendly_count : int:
# 	get():
# 		return targeted_friendlies.size()

func _init() -> void:
	Events.alarm_raised.connect(_on_alarm_raised)
	Events.alarm_ended.connect(_on_alarm_ended)


func _on_alarm_raised(raised_alarm, raiser : EnemyUnit):
	alarm_active = true
	encountered_friendlies = true
	known_friendly_count = raiser.awareness.targeted_friendly_count
	alarm = raised_alarm


func _on_alarm_ended():
	alarm_active = false
	if known_friendly_count == 0:
		# pseudocode - for enemy in enemy units, enemy awareness = unalerted
		pass
	else:
		# pseudocode - for enemy in enemy units, enemy awareness = alerted
		pass