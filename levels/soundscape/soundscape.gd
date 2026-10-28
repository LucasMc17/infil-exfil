class_name Soundscape
extends Node3D

func make_sound(pos : Vector3i, sound_res : Sound, exclude : Array[EnemyUnit] = []) -> void:
	var space = get_world_3d().get_direct_space_state()
	var sound_shape = SphereShape3D.new()
	sound_shape.radius = sound_res.radius
	var penetrating_shape = SphereShape3D.new()
	penetrating_shape.radius = sound_res.penetrating_radius

	var sound_query = PhysicsShapeQueryParameters3D.new()
	sound_query.collision_mask = 1

	sound_query.shape = sound_shape
	sound_query.transform = Transform3D(Basis(), pos)
	sound_query.collide_with_bodies = true
	sound_query.collide_with_areas = false

	var results = space.intersect_shape(sound_query)
	# var enemies : Array[EnemyUnit] = []
	for result in results:
		if result["collider"] and result["collider"] is EnemyUnit and !exclude.has(result["collider"]):
			# enemies.append(result["collider"])
			result["collider"].awareness.hear_sound(sound_res, NavigableGridMap.convert_global_to_grid_position(pos))
	# print(enemies)
