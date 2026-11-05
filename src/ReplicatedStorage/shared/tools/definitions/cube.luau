const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Cube",
	behaviours = {
		cube = {
			material = Enum.Material.Brick,
		},
	},
}

return definition
