const ReplicatedStorage = game:GetService("ReplicatedStorage")

const get_slot_tool = require(script.Parent.get_slot_tool)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)

local function slot_has_behaviour(slot: number, behaviour: tool_registry.behaviour): boolean
	const tool = get_slot_tool(slot)
	return tool ~= nil and tool.behaviour == behaviour
end

return slot_has_behaviour
