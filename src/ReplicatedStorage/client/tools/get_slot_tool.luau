const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.tools.registry)
const TOOLS = require(script.Parent.TOOL_LIST)

local function get_slot_tool(slot: number): registry.tool?
	const id = TOOLS[slot]
	if id == nil then
		return nil
	end
	const tool = registry.get(id)
	assert(tool ~= nil, `Slot {slot} holds unregistered tool "{id}".`)
	return tool
end

return get_slot_tool
