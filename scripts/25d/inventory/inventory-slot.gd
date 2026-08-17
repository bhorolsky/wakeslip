class_name InventorySlotUI
extends Panel
## Single inventory cell. Purely visual + input — reports clicks via
## signals instead of deciding what "use" or "drop" means itself.

signal use_requested(slot_index: int)
signal drop_requested(slot_index: int)

const EMPTY_LABEL := ""

@export var texture_rect: TextureRect
@export var label: Label

var _slot_index: int = -1
var _inventory: Inventory
var _is_selected: bool = false

func _ready() -> void:
	gui_input.connect(_on_gui_input)

## Binds this widget to one inventory slot and refreshes its visuals.
func setup(slot_index: int, inventory: Inventory) -> void:
	_slot_index = slot_index
	_inventory = inventory
	_refresh_display()

func _refresh_display() -> void:
	var slot_data := _inventory.get_slot_data(_slot_index)
	if slot_data == null or slot_data.item == null:
		_clear_display()
		return

	texture_rect.texture = slot_data.item.texture

func _clear_display() -> void:
	texture_rect.texture = null
	label.text = EMPTY_LABEL
	label.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			use_requested.emit(_slot_index)
		MOUSE_BUTTON_RIGHT:
			drop_requested.emit(_slot_index)

## Toggles the visual "selected" state of this slot (e.g. hotbar highlight).
func set_selected(is_selected: bool) -> void:
	_is_selected = is_selected
	modulate = Color(1.3, 1.3, 0.7) if _is_selected else Color(1, 1, 1)
