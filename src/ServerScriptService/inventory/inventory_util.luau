-- everything that changes an inventory takes the entity and replicates by itself
-- pure operations on a bare inventory table live in shared/inventory/inventory_logic

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
	-- fires with the entity whenever its selected tool might be different
	changed = signal.new(),
}

const dirty_entities: { [registry.entity]: true } = {}

const function replicate(entity: registry.entity): ()
	dirty_entities[entity] = nil
	-- players who left can't be fired to
	if type(entity) ~= "string" and entity.Parent == nil then
		return
	end
	inventory_util.changed:Fire(entity)
	registry.fire_client(entity, update_inventory, { inventory = entity_inventories[entity] })
end

-- batches every change made this frame into a single update
function inventory_util.mark_dirty(entity: registry.entity): ()
	if dirty_entities[entity] then
		return
	end
	dirty_entities[entity] = true
	task.defer(replicate, entity)
end

function inventory_util.generate_inventory(entity: registry.entity): inventory_types.inventory | false
	if entity_inventories[entity] then
		return false
	end

	const inventory = inventory_logic.create_empty()
	entity_inventories[entity] = inventory
	inventory_util.mark_dirty(entity)

	return inventory
end

function inventory_util.get_inventory(entity: registry.entity): inventory_types.inventory?
	return entity_inventories[entity]
end

-- breter98: This technically breaks the styling guidelines that functions should return a single value but this is much more convenient imo.
function inventory_util.get_row_and_column_from_slot(slot_index: number, row_size: number): (number, number)
	local i = slot_index - 1
	return i // row_size, i % row_size + 1
end

-- replicates the deletion so the client drops its copy, use the entity removed path for entities that are gone
function inventory_util.delete_inventory(entity: registry.entity): boolean
	if entity_inventories[entity] then
		entity_inventories[entity] = nil
		inventory_util.mark_dirty(entity)
		return true
	end
	return false
end

function inventory_util.clear_inventory(entity: registry.entity): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil then
		return false
	end

	for slot_index in inventory do
		inventory[slot_index] = "empty"
	end
	inventory_util.mark_dirty(entity)

	return true
end

function inventory_util.set_slot(entity: registry.entity, slot_index: number, slot: inventory_types.slot): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil or not inventory_logic.is_valid_slot(slot_index) then
		return false
	end

	inventory[slot_index] = slot
	inventory_util.mark_dirty(entity)

	return true
end

function inventory_util.give_item(entity: registry.entity, item: inventory_types.item_id, amount: number?, preferred_slot: number?): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil then
		return false
	end

	local slot_index = inventory_logic.find_free_slot(inventory, item)

	if preferred_slot and type(inventory[preferred_slot]) == "string" then
		slot_index = preferred_slot
	end
	if not slot_index then
		return false
	end

	const to_add = amount or 1
	const existing = inventory[slot_index]
	const current = if type(existing) == "table" then existing.amount else 0

	inventory[slot_index] = { item_id = item, amount = current + to_add }
	inventory_util.mark_dirty(entity)

	return true
end

function inventory_util.give_loadout(
	entity: registry.entity,
	loadout: { [number]: inventory_types.item_id }?,
	amounts: { [inventory_types.item_id]: number }?
): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil then
		return false
	end

	for slot_index, item in loadout or STARTING_LOADOUT do
		const amount = if amounts ~= nil then amounts[item] else nil
		inventory[slot_index] = { item_id = item, amount = amount or 1 }
	end
	inventory_util.mark_dirty(entity)

	return true
end

-- takes one item from the slot, returns whether there was anything to take
function inventory_util.consume_item_at_slot(entity: registry.entity, slot_index: number): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil then
		return false
	end

	const item = inventory[slot_index]
	if type(item) ~= "table" then
		return false
	end

	item.amount -= 1
	if item.amount <= 0 then
		inventory[slot_index] = "empty"
	end
	inventory_util.mark_dirty(entity)

	return true
end

function inventory_util.consume_item(entity: registry.entity, item: inventory_types.item_id): boolean
	const inventory = entity_inventories[entity]
	if inventory == nil then
		return false
	end

	const slot_index = inventory_logic.find_item(inventory, item)
	if type(slot_index) == "boolean" then
		return false
	end

	return inventory_util.consume_item_at_slot(entity, slot_index)
end

function inventory_util.get_selected_slot(entity: registry.entity): number
	return entity_selected_slots[entity] or 1
end

function inventory_util.set_selected_slot(entity: registry.entity, slot_index: number): ()
	entity_selected_slots[entity] = slot_index
	inventory_util.changed:Fire(entity)
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

function inventory_util.consume_selected_item(entity: registry.entity): boolean
	return inventory_util.consume_item_at_slot(entity, inventory_util.get_selected_slot(entity))
end

return inventory_util
