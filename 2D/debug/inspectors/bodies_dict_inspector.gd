class_name BodiesDictInspector
extends PanelContainer

@onready var _friendly_bodies : DebugKVPair = %FriendlyBodies
@onready var _enemy_bodies : DebugKVPair = %EnemyBodies
@onready var _friendly_body_buttons : VBoxContainer = %FriendlyBodyButtons
@onready var _enemy_body_buttons : VBoxContainer = %EnemyBodyButtons

var bodies : Utilities.BodiesDict

func refresh(new_dict : Utilities.BodiesDict = null) -> void:
	if new_dict:
		bodies = new_dict
	if bodies:
		_friendly_bodies.value = str(bodies.friendlies.size())
		_enemy_bodies.value = str(bodies.enemies.size())
		
		Utilities.clear_children(_friendly_body_buttons)
		Utilities.clear_children(_enemy_body_buttons)
		
		for friendly in bodies.friendlies.values():
			var button = Button.new()
			button.text = friendly.name
			button.pressed.connect(func(): Level.current_level.level_camera.jump_to_point(friendly.global_position))
			_friendly_body_buttons.add_child(button)
		for enemy in bodies.enemies.values():
			var button = Button.new()
			button.text = enemy.name
			button.pressed.connect(func(): Level.current_level.level_camera.jump_to_point(enemy.global_position))
			_enemy_body_buttons.add_child(button)