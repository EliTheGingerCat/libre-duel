const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Bow",
	image = "rbxassetid://85823189641687",
	behaviours = {
		bow = {},
	},
}

return definition
