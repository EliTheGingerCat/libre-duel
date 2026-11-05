const ReplicatedStorage = game:GetService("ReplicatedStorage")

const get_slot_tool = require(script.Parent.get_slot_tool)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

local function slot_has_behaviour(slot: number, behaviour: tool_types.behaviour): boolean
	const tool = get_slot_tool(slot)
	return tool ~= nil and tool_registry.has_behaviour(tool, behaviour)
end

return slot_has_behaviour
