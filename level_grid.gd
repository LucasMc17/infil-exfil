@tool
extends NavigableGridMap

@export var point_a := Vector3i.ZERO:
	set(val):
		point_a = val
		setup_astar_grid(walkable_items)
		do_debug_path.call_deferred(point_a, point_b)
@export var point_b := Vector3i.ZERO:
	set(val):
		point_b = val
		setup_astar_grid(walkable_items)
		do_debug_path.call_deferred(point_a, point_b)

func _ready() -> void:
	super()
	do_debug_path.call_deferred(point_a, point_b)

func _on_changed() -> void:
	setup_astar_grid(walkable_items)
	do_debug_path.call_deferred(point_a, point_b)