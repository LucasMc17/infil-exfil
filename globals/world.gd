## Globally available variables for ease of access during levels.
extends Node

## The currently loaded level.
var level : BaseLevel

## The logic module responsible for monitoring skill targeting.
var targeting := SkillTargetingModule.new()