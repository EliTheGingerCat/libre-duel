const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	inherits = "cube",
	name = "Red Clay",
	image = "rbxassetid://106372081249168",
	behaviours = {
		cube = {
			material = Enum.Material.SmoothPlastic,
			texture_id = "rbxassetid://70720324749589",
		},
	},
}

return definition
