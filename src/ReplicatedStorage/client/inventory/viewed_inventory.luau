-- the inventory that the inventory window shows and edits
-- that is the local one, unless the inventory of another player is open through invsee

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(script.Parent.client_inventory_util)
const get_inventory_amount = require(ReplicatedStorage.client.tools.get_inventory_amount)
const get_inventory_tool = require(ReplicatedStorage.client.tools.get_inventory_tool)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const invsee_state = require(script.Parent.invsee.invsee_state)
const invsee_util = require(script.Parent.invsee.invsee_util)
const signal = require(ReplicatedStorage.Packages.signal)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

local viewed_inventory = {
	-- fires after every change to either inventory, and when the viewed one switches
	on_change = signal.new(),
}

-- the other player whose inventory is open, nil while it's the local one
function viewed_inventory.get_target(): Player?
	return invsee_util.get_target()
end

function viewed_inventory.get_inventory(): inventory_types.inventory?
	if invsee_util.get_target() ~= nil then
		return invsee_util.get_inventory()
	end
	return client_inventory_util.get_inventory()
end

function viewed_inventory.get_slot_tool(slot: number): tool_types.tool?
	return get_inventory_tool(viewed_inventory.get_inventory(), slot)
end

function viewed_inventory.get_slot_amount(slot: number): number?
	return get_inventory_amount(viewed_inventory.get_inventory(), slot)
end

function viewed_inventory.swap_items(slot_1_index: number, slot_2_index: number): boolean
	if invsee_util.get_target() ~= nil then
		return invsee_util.swap_items(slot_1_index, slot_2_index)
	end
	return client_inventory_util.swap_items(slot_1_index, slot_2_index) ~= false
end

function viewed_inventory.quick_move(slot_index: number): boolean
	if invsee_util.get_target() ~= nil then
		return invsee_util.quick_move(slot_index)
	end
	return client_inventory_util.quick_move(slot_index) ~= false
end

const function on_any_change(): ()
	viewed_inventory.on_change:Fire()
end

client_inventory_util.on_change:Connect(on_any_change)
invsee_state.on_change:Connect(on_any_change)

return viewed_inventory
