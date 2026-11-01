local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function action_button(props: {
	image: string,
	anchor: number,
	button_ref: { current: ImageButton? },
	on_activate: () -> (),
})
	return create_element("ImageButton", {
		ref = props.button_ref,
		AnchorPoint = Vector2.new(props.anchor, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		Image = props.image,
		BorderSizePixel = 0,
		ZIndex = 21,
		[React.Event.Activated] = props.on_activate,
	}, create_element("UICorner", { CornerRadius = UDim.new(0, 8) }))
end

local function widget_bounds(props: {
	bounds_ref: { current: Frame? },
	delete_ref: { current: ImageButton? },
	settings_ref: { current: ImageButton? },
	on_delete: () -> (),
	on_settings: () -> (),
})
	local handles = {}
	for index, direction in
		{
			Vector2.new(0, 0),
			Vector2.new(0.5, 0),
			Vector2.new(1, 0),
			Vector2.new(1, 0.5),
			Vector2.new(1, 1),
			Vector2.new(0.5, 1),
			Vector2.new(0, 1),
			Vector2.new(0, 0.5),
		}
	do
		handles[`handle_{index}`] = create_element("Frame", {
			Position = UDim2.fromScale(direction.X, direction.Y),
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			ZIndex = 21,
		}, create_element("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 5 }))
	end
	return create_element("Frame", {
		ref = props.bounds_ref,
		Name = "widget_bounds",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, {
		stroke = create_element("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }),
		handles = create_element(React.Fragment, {}, handles),
		Delete = create_element(action_button, {
			button_ref = props.delete_ref,
			anchor = 1,
			image = "rbxassetid://78109412963567",
			on_activate = props.on_delete,
		}),
		Settings = create_element(action_button, {
			button_ref = props.settings_ref,
			anchor = 0,
			image = "rbxassetid://104330757164550",
			on_activate = props.on_settings,
		}),
	})
end

return widget_bounds
