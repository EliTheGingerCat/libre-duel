const ReplicatedStorage = game:GetService("ReplicatedStorage")

const STARTING_LOADOUT = require(ReplicatedStorage.shared.inventory.STARTING_LOADOUT)
const entity_inventories = require(script.Parent.entity_inventories)
const entity_selected_slots = require(script.Parent.entity_selected_slots)
const inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const registry = require(ReplicatedStorage.shared.entity.registry)
const signal = require(ReplicatedStorage.Packages.signal)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const update_inventory = ReplicatedStorage.remotes.update_inventory

local inventory_util = {
	created = signal.new(),
}

function inventory_util.generate_inventory(entity: registry.entity): inventory_types.inventory | false
	if entity_inventories[entity] then
		return false
	end

	const inventory = inventory_logic.create_empty()
	entity_inventories[entity] = inventory

	return inventory
end

function inventory_util.get_inventory(entity: registry.entity): inventory_types.inventory?
	return entity_inventories[entity]
end

function inventory_util.replicate(entity: registry.entity): ()
	if type(entity) ~= "string" then
		update_inventory:FireClient(entity, { inventory = entity_inventories[entity] })
	end
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

function inventory_util.delete_inventory(entity: registry.entity): boolean
	if entity_inventories[entity] then
		entity_inventories[entity] = nil
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

function inventory_util.give_loadout(
	inventory: inventory_types.inventory,
	loadout: { [number]: inventory_types.item_id }?
): inventory_types.inventory
	for slot, item in loadout or STARTING_LOADOUT do
		inventory[slot] = { item_id = item, amount = 1 }
	end

	return inventory
end

function inventory_util.get_selected_slot(entity: registry.entity): number
	return entity_selected_slots[entity] or 1
end

function inventory_util.set_selected_slot(entity: registry.entity, slot_index: number): ()
	entity_selected_slots[entity] = slot_index
end

function inventory_util.clear_selected_slot(entity: registry.entity): ()
	entity_selected_slots[entity] = nil
end

function inventory_util.get_selected_tool(entity: registry.entity): tool_types.tool?
	const inventory = inventory_util.get_inventory(entity)
	if inventory == nil then
		return nil
	end
	const item = inventory[inventory_util.get_selected_slot(entity)]
	if type(item) ~= "table" then
		return nil
	end
	return tool_registry.resolve(item.item_id, item.data)
end

function inventory_util.has_behaviour(entity: registry.entity, behaviour: tool_types.behaviour): boolean
	const tool = inventory_util.get_selected_tool(entity)
	return tool ~= nil and tool_registry.has_behaviour(tool, behaviour)
end

inventory_util.is_hotbar_slot = inventory_logic.is_hotbar_slot
inventory_util.move_item = inventory_logic.move_item
inventory_util.quick_move = inventory_logic.quick_move
inventory_util.swap_items = inventory_logic.swap_items

return inventory_util
