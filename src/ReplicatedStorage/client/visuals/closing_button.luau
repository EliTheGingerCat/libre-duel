local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function closing_button()
	return create_element("ImageButton", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -80, 0, 5),
		Size = UDim2.fromOffset(42, 42),
		Image = "rbxassetid://72160170469319",
		ZIndex = 2,
	})
end

return closing_button
