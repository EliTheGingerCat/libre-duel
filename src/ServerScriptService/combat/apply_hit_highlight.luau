local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local colours = require(ReplicatedStorage.modules.ui.colours)

local function apply_hit_highlight(character: Model, duration: number, colour: Color3?)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = colour or colours.rose_700
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.Parent = character

	Debris:AddItem(highlight, duration)
end

return apply_hit_highlight
