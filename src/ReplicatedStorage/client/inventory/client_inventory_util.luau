const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const client_inventory = require(script.Parent.client_inventory)
const inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const registry = require(ReplicatedStorage.shared.entity.registry)
const remote_id = require(script.Parent.remote_id)
const signal = require(ReplicatedStorage.Packages.signal)

const update_inventory = ReplicatedStorage.remotes.update_inventory

local inventory_util = {
	-- fires after every change to the local inventory, including predictions
	on_change = signal.new(),
}

const LOCAL_ENTITY: registry.entity = Players.LocalPlayer

function inventory_util.get_inventory(): inventory_types.inventory?
	return client_inventory[LOCAL_ENTITY]
end

function inventory_util.set_inventory(inventory: inventory_types.inventory?): ()
	if inventory then
		client_inventory[LOCAL_ENTITY] = inventory
	else
		client_inventory[LOCAL_ENTITY] = nil
	end
	inventory_util.on_change:Fire()
end

inventory_util.find_free_slot = inventory_logic.find_free_slot

-- predicts the action locally, the server answers with the authoritative inventory
local function request_action(
	action: inventory_types.inventory_action,
	predict: (inventory_types.inventory, number, number) -> boolean,
	from_slot_index: number,
	to_slot_index: number
): inventory_types.inventory | false
	const inventory = inventory_util.get_inventory()
	if not inventory or not predict(inventory, from_slot_index, to_slot_index) then
		return false
	end
	const request: inventory_types.inventory_request = {
		action = action,
		from = from_slot_index,
		to = to_slot_index,
		id = remote_id.next_id(),
	}
	update_inventory:FireServer(request)
	inventory_util.on_change:Fire()
	return inventory
end

function inventory_util.swap_items(slot_1_index: number, slot_2_index: number): inventory_types.inventory | false
	return request_action("swap_items", inventory_logic.swap_items, slot_1_index, slot_2_index)
end

function inventory_util.quick_move(slot_index: number): inventory_types.inventory | false
	return request_action("quick_move", inventory_logic.quick_move, slot_index, slot_index)
end

function inventory_util.move_item(from_slot_index: number, to_slot_index: number): inventory_types.inventory | false
	return request_action("move_item", inventory_logic.move_item, from_slot_index, to_slot_index)
end

return inventory_util
