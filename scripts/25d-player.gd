extends CharacterBody3D

# this is 2.5d player script

@export var walk_speed := 5.0
@export var sprint_speed := 7.0
@export var jump_velocity := 5.0
@export var gravity := 15.0
@export var mouse_sensitivity := 0.005

@onready var interact_ray: RayCast3D = $InteractRayCast3D
@onready var ui = get_tree().current_scene.get_node("25d-ui")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := Vector3(input_dir.x, 0.0, input_dir.y)

	direction = transform.basis * direction
	direction.y = 0.0
	direction = direction.normalized()

	var current_speed := walk_speed

	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	if Input.is_action_just_pressed("interact"):
		interact()

	update_crosshair()
	move_and_slide()

func update_crosshair():
	if not interact_ray.is_colliding():
		ui.set_cursor_default()
		return

	var object := interact_ray.get_collider()

	if object.has_method("interact"):
		ui.set_cursor_interact()
	else:
		ui.set_cursor_default()

func interact():
	if not interact_ray.is_colliding():
		return

	var object := interact_ray.get_collider()

	if object.has_method("interact"):
		object.interact()
