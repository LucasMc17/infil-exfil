class_name VisibleZone
extends Area3D

@export var friendly : FriendlyUnit

var _detection_check_queued := false

var vision_targets : Array[VisibilityPoint]:
	get():
		var result : Array[VisibilityPoint]
		for point in get_children():
			if point is VisibilityPoint:
				result.append(point)
		return result

func queue_detection_check():
	_detection_check_queued = true


func _check_detection():
	_detection_check_queued = false
	var colliders = get_overlapping_areas()
	var vision_zones = colliders.filter(func(collider): return collider is VisionZone)
	for zone : VisionZone in vision_zones:
		print('potential sighting')
		var vis_score = 0
		for point : VisibilityPoint in vision_targets:
			var ray := PhysicsRayQueryParameters3D.create(zone.global_position, point.global_position)
			var collision = get_world_3d().direct_space_state.intersect_ray(ray)
			if collision and collision.collider == friendly:
				vis_score += 1
		print(vis_score)
		if vis_score > 1:
			print("He sees ya.")


func _physics_process(_delta: float) -> void:
	if _detection_check_queued:
		_check_detection()