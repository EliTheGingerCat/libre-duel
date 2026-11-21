const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Arrow",
	image = "rbxassetid://102461617513391",
	mesh = "rbxassetid://131375476557394",
	behaviours = {},
}

return definition
