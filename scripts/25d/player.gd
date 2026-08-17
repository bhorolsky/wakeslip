class_name Player
extends CharacterBody3D
## First-person 2.5D controller: movement, look, interaction raycasting,
## and wiring the player's Inventory to the HUD.

@export_group("Movement")
@export var walk_speed := 5.0
@export var sprint_speed := 7.0
@export var jump_velocity := 5.0
@export var gravity := 15.0

@export_group("Camera")
@export var mouse_sensitivity := 0.005

@export_group("References")
@export var inventory: Inventory
@export var inventory_ui: Node  ## Expects: inventory (settable), update_inventory(), toggle_inventory(), set_cursor_default(), set_cursor_interact()
@export var held_item_view: Node  ## Expects: show_item(item: Item), clear()

@onready var interact_ray: RayCast3D = $InteractRayCast3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_ensure_inventory_exists()
	_link_inventory_to_hud()
	_link_inventory_to_held_view()

func _ensure_inventory_exists() -> void:
	if inventory != null:
		return
	inventory = Inventory.new()
	add_child(inventory)

## Gives the HUD a live reference to this player's inventory and
## subscribes it to future changes. This fixes the previous bug where
## the HUD's `inventory` field was declared but never assigned.
func _link_inventory_to_hud() -> void:
	if inventory_ui == null:
		return
	inventory_ui.inventory = inventory
	inventory.inventory_changed.connect(inventory_ui.update_inventory)
	inventory.selected_slot_changed.connect(inventory_ui._on_selected_slot_changed) 
	inventory_ui.update_inventory()

## Wires the "in-hand" sprite to inventory state so it updates on
## selection change and on pickup/use/drop.
func _link_inventory_to_held_view() -> void:
	if held_item_view == null:
		return
	inventory.inventory_changed.connect(_update_held_item_view)
	inventory.selected_slot_changed.connect(func(_i): _update_held_item_view())
	_update_held_item_view()

func _update_held_item_view() -> void:
	var slot_data := inventory.get_slot_data(inventory.selected_slot)
	if slot_data != null and slot_data.item != null:
		held_item_view.show_item(slot_data.item)
	else:
		held_item_view.clear()

func pick_up_item(item: Item) -> bool:
	return inventory.add_item(item)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		_toggle_inventory_ui()
		return

	_handle_slot_selection_input()

func _handle_slot_selection_input() -> void:
	if inventory == null:
		return
	if Input.is_action_just_pressed("select_next_slot"):
		inventory.select_next_slot()
	elif Input.is_action_just_pressed("select_previous_slot"):
		inventory.select_previous_slot()

func _toggle_inventory_ui() -> void:
	if inventory_ui == null:
		return
	inventory_ui.toggle_inventory()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_jump()
	_apply_movement()
	_handle_interaction_input()
	_update_crosshair()
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

## TODO: delete this
func jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func _apply_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _apply_movement() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	direction.y = 0.0
	direction = direction.normalized()

	var current_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

func _handle_interaction_input() -> void:
	if Input.is_action_just_pressed("interact"):
		_interact_with_target()

## Returns whatever the interact raycast is currently hitting, or null.
func _get_interact_target() -> Node:
	if not interact_ray.is_colliding():
		return null
	return interact_ray.get_collider()

func _update_crosshair() -> void:
	if inventory_ui == null:
		return
	var target := _get_interact_target()
	if target != null and target.has_method("interact"):
		inventory_ui.set_cursor_interact()
	else:
		inventory_ui.set_cursor_default()

func _interact_with_target() -> void:
	var target := _get_interact_target()
	if target == null or not target.has_method("interact"):
		return
	target.interact(self)