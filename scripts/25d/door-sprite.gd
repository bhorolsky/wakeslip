class_name DoorSprite
extends StaticBody3D
## Simple two-state (open/closed) sliding-texture door.

enum DoorState { CLOSED, OPEN }

@export var open_duration_seconds := 3.0
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@onready var sprite: Sprite3D = $Sprite3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _state: DoorState = DoorState.CLOSED

## `_actor` is unused but kept so DoorSprite matches the same interact(actor)
## signature as every other interactable in the game.
func interact(_actor: Node) -> void:
	if _state == DoorState.OPEN:
		return
	_open_door()

func _open_door() -> void:
	_state = DoorState.OPEN
	sprite.texture = open_texture
	collision.disabled = true

	await get_tree().create_timer(open_duration_seconds).timeout
	_close_door()

func _close_door() -> void:
	_state = DoorState.CLOSED
	sprite.texture = closed_texture
	collision.disabled = false