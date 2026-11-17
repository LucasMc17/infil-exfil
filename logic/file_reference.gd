## Class for loading files as they become needed. Best for use with small files, like the textures which a sprite must switch between, for example. The idea here is to avoid preloading resources, or even loading them at the start of the program. Each instance of this class will store only a reference to the UID or path of the resource until the first time the resource's value is actually required. At that point, it will load the resource into memory and keep it there for all future uses.
class_name FileReference
extends Object

## The UID of this file within the repository. A path can be used as well, but UIDs are generally more stable.
var id : String
## The file this instance represents.
var value : Resource = null:
	get():
		if !value:
			value = load(id)
		return value

func _init(i : String) -> void:
	id = i
