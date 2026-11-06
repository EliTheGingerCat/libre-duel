const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Sword",
	image = "rbxassetid://89657284108555",
	behaviours = {
		sword = {},
	},
}

return definition
