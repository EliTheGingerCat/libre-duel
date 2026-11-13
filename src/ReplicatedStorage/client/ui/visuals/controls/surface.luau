local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.gradient_stroke)
local shadow = require(script.Parent.Parent.shadow)

const function surface(props: { radius: number?, danger: boolean?, colour: Color3? })
	return React.createElement(React.Fragment, {}, {
		corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, props.radius or 25) }),
		shadow = React.createElement(shadow, {
			ShowBehindParent = false,
			BlurRadius = UDim.new(0, 8),
			Transparency = 0.3,
		}),
		stroke = React.createElement(gradient_stroke, {
			colour = props.colour or (if props.danger then COLOURS.danger else nil),
		}),
	})
end

return surface
