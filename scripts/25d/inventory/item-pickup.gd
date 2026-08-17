class_name ItemPickup
extends StaticBody3D
## World object that grants `item` to whichever actor interacts with it.

@export var item: Item:
	set(value):
		item = value
		_refresh_visual()

@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	_refresh_visual()

func _refresh_visual() -> void:
	if sprite == null or item == null:
		return
	sprite.texture = item.texture

## Called by the interacting actor (expected to expose pick_up_item()).
func interact(actor: Node) -> void:
	if actor == null or not actor.has_method("pick_up_item"):
		return
	if actor.pick_up_item(item):
		queue_free()