class_name Item
extends Resource
## Base resource describing a collectible / usable inventory item

@export var id: String = "item_default"
@export var display_name: String = "Item"
@export var texture: Texture2D
@export var held_texture: Texture2D

func use(_actor: Node) -> bool:
	print("Used: ", display_name)
	return true