const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const definition: tool_types.definition = {
	name = "Bow",
	image = "rbxassetid://85823189641687",
	mesh = "rbxassetid://131898431371037",
	behaviours = {
		bow = {
			draw_frames = {
				{ mesh = "rbxassetid://78638270025916", texture = "rbxassetid://98772881290658" },
				{ mesh = "rbxassetid://109864196675557", texture = "rbxassetid://91700574511481" },
				{ mesh = "rbxassetid://74025234679745", texture = "rbxassetid://111708050076479" },
			},
		},
	},
}

return definition
