local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local registry = require(script.Parent.registry)

local create_element = React.createElement

const function settings(props: { selected: registry.entry?, display_order: number, on_close: () -> () })
	local selected = props.selected
	return create_element(
		menu_window,
		{
			name = "HudSettings",
			title = if selected then `{selected.screen.Name} settings` else "HUD settings",
			size = Vector2.new(600, 320),
			enabled = selected ~= nil,
			display_order = props.display_order,
			on_close = props.on_close,
		},
		create_element("Frame", {
			Name = "controls",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 90),
			Size = UDim2.new(1, -100, 0, 180),
			BackgroundTransparency = 1,
		}, {
			hint = create_element("TextLabel", {
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "Uh oh, you spotted an incomplete feature",
				TextSize = 30,
				TextYAlignment = "Center",
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = FONTS.bold,
			}),
		})
	)
end

return settings
