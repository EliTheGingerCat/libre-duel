const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	inherits = "cube",
	name = "Blue Clay",
	image = "rbxassetid://74900679118313",
	behaviours = {
		cube = {
			material = Enum.Material.SmoothPlastic,
			texture_id = "rbxassetid://72876879336754",
		},
	},
}

return definition
