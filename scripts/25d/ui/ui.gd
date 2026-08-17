class_name PlayerHud
extends CanvasLayer
## HUD: crosshair state + rebuilding the inventory grid from Inventory data.
## Talks to gameplay nodes only through @export references and signals —
## never reaches into the scene tree by node name.

@export var cursor_default: Texture2D
@export var cursor_interact: Texture2D
@export var slot_scene: PackedScene
@export var grid_container: GridContainer
@export var player: Node  ## Passed to Inventory.use_item() as the acting node.

@onready var crosshair: TextureRect = $crosshair

var inventory: Inventory  ## Assigned by Player._link_inventory_to_hud().

func set_cursor_default() -> void:
	crosshair.texture = cursor_default

func set_cursor_interact() -> void:
	crosshair.texture = cursor_interact

## Rebuilds all slot widgets from the current inventory state.
func update_inventory() -> void:
	if inventory == null:
		return
	_clear_slots()
	_build_slots()

func _clear_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()

func _build_slots() -> void:
	for i in range(inventory.slots.size()):
		var slot := slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.setup(i, inventory)
		slot.set_selected(i == inventory.selected_slot)
		slot.use_requested.connect(_on_slot_use_requested)
		slot.drop_requested.connect(_on_slot_drop_requested)

func _on_selected_slot_changed(new_index: int) -> void:
	for child in grid_container.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child.get_index() == new_index)

func _on_slot_use_requested(slot_index: int) -> void:
	if inventory != null and player != null:
		inventory.use_item(slot_index, player)

func _on_slot_drop_requested(slot_index: int) -> void:
	if inventory != null:
		inventory.remove_item(slot_index)

func toggle_inventory() -> void:
	visible = not visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	if visible:
		update_inventory()
