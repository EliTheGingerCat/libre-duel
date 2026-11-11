local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

-- The counter in the bottom right of an item. Shows nothing unless there's more than one.
local function item_amount(props: { amount: number? })
	if props.amount == nil or props.amount <= 1 then
		return nil
	end
	return create_element("TextLabel", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		FontFace = FONTS.semi_bold,
		Name = "amount",
		Position = UDim2.fromScale(0.95, 1),
		Size = UDim2.fromScale(0.6, 0.4),
		Text = tostring(props.amount),
		TextColor3 = COLOURS.white,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
	})
end

return item_amount
