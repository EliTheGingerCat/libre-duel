const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	inherits = "cube",
	name = "White Clay",
	behaviours = {
		cube = {
			colour = Color3.new(1, 1, 1),
			material = Enum.Material.SmoothPlastic,
		},
	},
}

return definition
