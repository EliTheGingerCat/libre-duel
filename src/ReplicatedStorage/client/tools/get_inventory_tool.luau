const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- nil while the slot is empty or there is no inventory
const function get_inventory_tool(inventory: inventory_types.inventory?, slot: number): tool_types.tool?
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

return get_inventory_tool
