const ReplicatedStorage = game:GetService("ReplicatedStorage")

const STARTING_LOADOUT = require(ReplicatedStorage.shared.inventory.STARTING_LOADOUT)
const inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const player_inventories = require(script.Parent.player_inventories)
const player_selected_slots = require(script.Parent.player_selected_slots)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)

local inventory_util = {}

local function inventory_key(player: Player): string
	return tostring(player.UserId)
end

function inventory_util.generate_inventory(player: Player): inventory_types.inventory | false
	const key = inventory_key(player)
	if player_inventories[key] then
		return false
	end

	const inventory = inventory_logic.create_empty()
	player_inventories[key] = inventory

	return inventory
end

function inventory_util.get_inventory_from_player(player: Player): inventory_types.inventory?
	return player_inventories[inventory_key(player)]
end

-- breter98: This technically breaks the styling guidelines that functions should return a single value but this is much more convenient imo.
function inventory_util.get_row_and_column_from_slot(slot_index: number, row_size: number): (number, number)
	local i = slot_index - 1
	return i // row_size, i % row_size + 1
end

function inventory_util.clear_inventory(inventory: inventory_types.inventory): inventory_types.inventory
	for i in inventory do
		inventory[i] = false
	end

	return inventory
end

function inventory_util.delete_inventory(player: Player): boolean
	const key = inventory_key(player)
	if player_inventories[key] then
		player_inventories[key] = nil
		return true
	end
	return false
end

function inventory_util.give_item(inventory: inventory_types.inventory, item: inventory_types.item_id): boolean
	local slot = inventory_logic.find_free_slot(inventory)
	if not slot then
		return false
	end

	inventory[slot] = { item_id = item, amount = 1 }

	return true
end

function inventory_util.give_loadout(inventory: inventory_types.inventory): inventory_types.inventory
	for slot, item in STARTING_LOADOUT do
		inventory[slot] = { item_id = item, amount = 1 }
	end

	return inventory
end

function inventory_util.get_selected_slot(player: Player): number
	return player_selected_slots[inventory_key(player)] or 1
end

function inventory_util.set_selected_slot(player: Player, slot_index: number): ()
	player_selected_slots[inventory_key(player)] = slot_index
end

function inventory_util.clear_selected_slot(player: Player): ()
	player_selected_slots[inventory_key(player)] = nil
end

-- the tool in the slot the client says is selected, nil if empty or dead
function inventory_util.get_selected_tool(player: Player): tool_registry.tool?
	const inventory = inventory_util.get_inventory_from_player(player)
	if inventory == nil then
		return nil
	end
	const item = inventory[inventory_util.get_selected_slot(player)]
	if type(item) ~= "table" then
		return nil
	end
	return tool_registry.get(item.item_id)
end

function inventory_util.has_tool(player: Player, tool_id: string): boolean
	const tool = inventory_util.get_selected_tool(player)
	return tool ~= nil and tool.id == tool_id
end

function inventory_util.has_behaviour(player: Player, behaviour: tool_registry.behaviour): boolean
	const tool = inventory_util.get_selected_tool(player)
	return tool ~= nil and tool.behaviour == behaviour
end

inventory_util.is_hotbar_slot = inventory_logic.is_hotbar_slot
inventory_util.move_item = inventory_logic.move_item
inventory_util.quick_move = inventory_logic.quick_move
inventory_util.swap_items = inventory_logic.swap_items

return inventory_util
