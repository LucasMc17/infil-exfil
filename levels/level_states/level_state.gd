## A state representing the current status of the entire level, ie player's turn or enemy's turn.
class_name LevelState
extends State

## The level this state corresponds to.
@export var level : BaseLevel

## Whether or not the camera is manually movable in this state.
var allow_cam_movement := true