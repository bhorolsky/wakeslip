class_name Inventory
extends Node
## Owns and mutates the player's item slots. Pure game-state logic —
## has zero knowledge of UI, scene tree layout, or input.

signal inventory_changed
signal selected_slot_changed(new_index: int)

@export var max_slots: int = 6

var slots: Array[InventorySlotData] = []
var selected_slot: int = 0 

## Selects an arbitrary slot by index.
func select_slot(index: int) -> void:
	if not _is_valid_index(index) or index == selected_slot:
		return
	selected_slot = index
	selected_slot_changed.emit(selected_slot)

## Moves selection forward, wrapping around.
func select_next_slot() -> void:
	if slots.is_empty():
		return
	select_slot((selected_slot + 1) % slots.size())

## Moves selection backward, wrapping around.
func select_previous_slot() -> void:
	if slots.is_empty():
		return
	select_slot((selected_slot - 1 + slots.size()) % slots.size())

func _ready() -> void:
	slots.resize(max_slots)

## or filling the first empty slot. Returns false if inventory is full.
func add_item(item: Item) -> bool:
	if _place_in_empty_slot(item):
		return true
	return false

func _place_in_empty_slot(item: Item) -> bool:
	for i in range(slots.size()):
		if slots[i] != null:
			continue

		var slot_data := InventorySlotData.new()
		slot_data.item = item
		slots[i] = slot_data
		inventory_changed.emit()
		return true
	return false

## Removes one unit from the given slot, clearing the slot if it hits zero.
func remove_item(slot_index: int) -> void:
	if not _is_valid_index(slot_index):
		return
	if slots[slot_index] == null:
		return
	slots[slot_index] = null
	inventory_changed.emit()

## Triggers the item's use() effect on `actor`, then removes one unit on success.
func use_item(slot_index: int, actor: Node) -> bool:
	if not _is_valid_index(slot_index):
		return false
	var slot_data := slots[slot_index]
	if slot_data == null or slot_data.item == null:
		return false

	var was_used := slot_data.item.use(actor)
	if was_used:
		remove_item(slot_index)
	return was_used

func get_slot_data(slot_index: int) -> InventorySlotData:
	if not _is_valid_index(slot_index):
		return null
	return slots[slot_index]

func _is_valid_index(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < slots.size()