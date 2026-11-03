local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.gradient_stroke)

local function surface(props: { radius: number?, danger: boolean? })
	return React.createElement(React.Fragment, {}, {
		corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, props.radius or 25) }),
		shadow = React.createElement("UIShadow", {
			ShowBehindParent = false,
			BlurRadius = UDim.new(0, 8),
			Transparency = 0.3,
		}),
		stroke = React.createElement(gradient_stroke, {
			colour = if props.danger then Color3.new(177 / 255, 76 / 255, 78 / 255) else nil,
		}),
	})
end

return surface
