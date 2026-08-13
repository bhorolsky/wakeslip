extends CanvasLayer

@export var cursor_default: Texture2D
@export var cursor_interact: Texture2D

@onready var crosshair: TextureRect = $crosshair


func set_cursor_default():
	crosshair.texture = cursor_default


func set_cursor_interact():
	crosshair.texture = cursor_interact
