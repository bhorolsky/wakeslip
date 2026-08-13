extends StaticBody3D

@export var open_time := 3.0
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

@onready var sprite: Sprite3D = $Sprite3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var is_open := false


func interact():
	if is_open:
		return

	open_door()


func open_door():
	is_open = true

	sprite.texture = open_texture

	collision.disabled = true

	await get_tree().create_timer(open_time).timeout

	close_door()


func close_door():
	sprite.texture = closed_texture
	collision.disabled = false

	is_open = false
