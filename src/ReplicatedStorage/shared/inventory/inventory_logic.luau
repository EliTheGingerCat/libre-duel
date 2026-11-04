-- pure inventory operations shared by client prediction and the server

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const INVENTORY_CONSTANTS = require(ReplicatedStorage.shared.inventory.INVENTORY_CONSTANTS)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

local inventory_logic = {}

function inventory_logic.create_empty(): inventory_types.inventory
	local inventory: inventory_types.inventory = {}
	for slot = 1, INVENTORY_CONSTANTS.INVENTORY_SIZE do
		inventory[slot] = false
	end
	return inventory
end

-- rejects non-numbers, NaN, non-integers and out of range indices
function inventory_logic.is_valid_slot(slot_index: unknown): boolean
	return type(slot_index) == "number"
		and slot_index == slot_index
		and slot_index % 1 == 0
		and slot_index >= 1
		and slot_index <= INVENTORY_CONSTANTS.INVENTORY_SIZE
end

function inventory_logic.find_free_slot(inventory: inventory_types.inventory): number?
	for i, slot in ipairs(inventory) do
		if slot == false then
			return i
		end
	end

	return nil
end

function inventory_logic.swap_items(
	inventory: inventory_types.inventory,
	slot_1_index: number,
	slot_2_index: number
): boolean
	if not inventory_logic.is_valid_slot(slot_1_index) or not inventory_logic.is_valid_slot(slot_2_index) then
		return false
	end
	inventory[slot_1_index], inventory[slot_2_index] = inventory[slot_2_index], inventory[slot_1_index]
	return true
end

-- moves an item into an empty slot
function inventory_logic.move_item(
	inventory: inventory_types.inventory,
	from_slot_index: number,
	to_slot_index: number
): boolean
	if not inventory_logic.is_valid_slot(from_slot_index) or not inventory_logic.is_valid_slot(to_slot_index) then
		return false
	end
	if inventory[from_slot_index] == false or inventory[to_slot_index] ~= false then
		return false
	end
	inventory[from_slot_index], inventory[to_slot_index] = false, inventory[from_slot_index]
	return true
end

function inventory_logic.is_hotbar_slot(slot_index: number): boolean
	return inventory_logic.is_valid_slot(slot_index) and slot_index <= INVENTORY_CONSTANTS.COLUMNS
end

-- the slot a quick move would put the item in: the first free slot on the other side of the hotbar
function inventory_logic.find_quick_move_slot(inventory: inventory_types.inventory, from_slot_index: number): number?
	if not inventory_logic.is_valid_slot(from_slot_index) or inventory[from_slot_index] == false then
		return nil
	end
	const from_hotbar = inventory_logic.is_hotbar_slot(from_slot_index)
	const first = if from_hotbar then INVENTORY_CONSTANTS.COLUMNS + 1 else 1
	const last = if from_hotbar then INVENTORY_CONSTANTS.INVENTORY_SIZE else INVENTORY_CONSTANTS.COLUMNS
	for slot_index = first, last do
		if inventory[slot_index] == false then
			return slot_index
		end
	end
	return nil
end

-- like shift clicking in minecraft, moves an item between the hotbar and the rest of the inventory
-- `_to_slot_index` is unused, it keeps the signature the same as the other actions
function inventory_logic.quick_move(
	inventory: inventory_types.inventory,
	from_slot_index: number,
	_to_slot_index: number
): boolean
	const to_slot_index = inventory_logic.find_quick_move_slot(inventory, from_slot_index)
	if to_slot_index == nil then
		return false
	end
	inventory[to_slot_index], inventory[from_slot_index] = inventory[from_slot_index], false
	return true
end

return inventory_logic
