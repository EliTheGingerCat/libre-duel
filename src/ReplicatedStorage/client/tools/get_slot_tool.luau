const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
const get_inventory_tool = require(script.Parent.get_inventory_tool)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- reads the tool from the local inventory, nil while the inventory hasn't arrived or the player is dead
const function get_slot_tool(slot: number): tool_types.tool?
	return get_inventory_tool(client_inventory_util.get_inventory(), slot)
end

return get_slot_tool
