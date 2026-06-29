## Resource representing a potential connection between two tiles in the [NavigableGridMap]. Is possessed by one [Tile] ('from') and refers to a specific neighbor of that [Tile] ('to').
class_name TileConnection 
extends Resource

## When enabled, the connection will not be built between this connections 'from' and 'to', unless the 'to' also attempts to build a connection to the 'from'. In this way, both [Tile]s must 'see' each other in order to build a navigable connection.
## [br]When disabled, the connection is built as soon as the 'from' [Tile] 'sees' the 'to' [Tile], regardless of whether or not the attempt to connect is mutual.
@export var must_be_two_way := true
## A name for this connection, purely for the user's benefit. For example, 'forward', 'backward', 'left', or 'right'.
@export var name : String
## The relative position of the 'to' [Tile] to the 'from' [Tile] in this potential connection.
@export var relative_position : Vector3i