class_name HeldItemView
extends Sprite3D
## Displays the currently selected inventory item as a fixed sprite
## anchored to the camera (classic FPS "viewmodel" style).
## Pure display — knows nothing about what an item does when used.

func show_item(item: Item) -> void:
	if item == null or item.held_texture == null:
		clear()
		return
	texture = item.held_texture
	visible = true

func clear() -> void:
	visible = false
