const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- reads the tool from the local inventory, nil while the inventory hasn't arrived or the player is dead
const function get_slot_tool(slot: number): tool_types.tool?
	const inventory = client_inventory_util.get_inventory()
	if inventory == nil then
		return nil
	end
	const item = inventory[slot]
	if type(item) ~= "table" then
		return nil
	end
	const tool = tool_registry.resolve(item.item_id, item.data)
	if not tool then
		return nil
	end
	return tool
end

return get_slot_tool
