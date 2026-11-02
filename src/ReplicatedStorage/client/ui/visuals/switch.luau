local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local use_ui_motion = require(script.Parent.use_ui_motion)

local create_element = React.createElement

const COLOURS = {
	active = Color3.fromRGB(76, 177, 80),
	not_active = Color3.fromRGB(177, 76, 78),
}

type props = {
	active: boolean,
}

local function switch(props: props)
	local motion = use_ui_motion(if props.active then 1 else 0)
	local function thumb_position(value: number): UDim2
		return UDim2.new(value, 15 - 30 * value, 0.5, 0)
	end
	return create_element(
		"Frame",
		{ --track
			BackgroundColor3 = Color3.fromRGB(54, 54, 54),
			Size = UDim2.fromOffset(64, 32),
		},
		create_element("UIShadow", { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		create_element("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		create_element(
			"UIStroke",
			{
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			},
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
			})
		),
		create_element(
			"Frame",
			{ --thumb
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(54, 54, 54),
				Position = motion:map(thumb_position),
				Size = UDim2.fromOffset(30, 30),
			},
			create_element("UIShadow", { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
			create_element("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			create_element(
				"UIStroke",
				{
					Color = Color3.fromRGB(255, 255, 255),
					Thickness = 2,
				},
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(
							0,
							if props.active == true then COLOURS.active else COLOURS.not_active
						),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
					}),
				})
			)
		)
	)
end

return switch
