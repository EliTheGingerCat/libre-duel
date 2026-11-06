const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Pickaxe",
	image = "rbxassetid://111079693280540",
	behaviours = {
		pickaxe = {},
	},
}

return definition
