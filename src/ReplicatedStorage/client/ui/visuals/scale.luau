local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local use_viewport_scale = require(script.Parent.use_viewport_scale)

local function scale_element()
	return React.createElement("UIScale", { Scale = use_viewport_scale() })
end

return scale_element
