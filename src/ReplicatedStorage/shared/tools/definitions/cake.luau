const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Cake",
	image = "rbxassetid://101828243662648",
	mesh = "rbxassetid://74499338998807",
	behaviours = {
		cake = {},
	},
}

return definition
