local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
local React = require(ReplicatedStorage.Packages.react)
local editor_drag_detector = require(script.Parent.editor_drag_detector)

local create_element = React.createElement

local function action_button(props: {
	image: string,
	anchor: number,
	side: "left" | "right",
	colour: Color3?,
	button_ref: { current: ImageButton? },
	visible: boolean?,
	on_activate: () -> (),
})
	return create_element(
		"ImageButton",
		{
			ref = props.button_ref,
			Visible = props.visible == true,
			AnchorPoint = Vector2.new(props.anchor, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(36, 36),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			Image = props.image,
			ImageColor3 = props.colour,
			BorderSizePixel = 0,
			ZIndex = 22,
			[React.Event.Activated] = props.on_activate,
		},
		create_element("UICorner", {
			BottomLeftRadius = if props.side == "right" then UDim.new(0, 0) else UDim.new(0, 8),
			TopLeftRadius = if props.side == "right" then UDim.new(0, 0) else UDim.new(0, 8),
			BottomRightRadius = if props.side == "left" then UDim.new(0, 0) else UDim.new(0, 8),
			TopRightRadius = if props.side == "left" then UDim.new(0, 0) else UDim.new(0, 8),
		})
	)
end

local function widget_bounds(props: {
	bounds_ref: { current: Frame? },
	move_ref: { current: Frame? },
	delete_ref: { current: ImageButton? },
	settings_ref: { current: ImageButton? },
	rectangle: { position: Vector2, size: Vector2 },
	hidden: boolean,
	on_delete: () -> (),
	on_settings: () -> (),
	on_drag_start: (UIDragDetector, Vector2, Vector2?) -> (),
	on_drag_move: (UIDragDetector, Vector2) -> (),
	on_drag_finish: (UIDragDetector, Vector2) -> (),
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
			Name = `handle_{index}`,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(direction.X, direction.Y),
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
			Visible = false,
			Active = true,
			Selectable = true,
			ZIndex = 21,
		}, {
			marker = create_element("Frame", {
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1,
				ZIndex = 21,
			}, { stroke = create_element("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 5 }) }),
			drag = create_element(editor_drag_detector, {
				handle = direction * 2 - Vector2.one,
				on_start = props.on_drag_start,
				on_move = props.on_drag_move,
				on_finish = props.on_drag_finish,
			}),
		})
	end
	return create_element("Frame", {
		ref = props.bounds_ref,
		Name = "widget_bounds",
		Position = UDim2.fromOffset(props.rectangle.position.X, props.rectangle.position.Y),
		Size = UDim2.fromOffset(props.rectangle.size.X, props.rectangle.size.Y),
		Visible = not props.hidden,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 20,
	}, {
		move = create_element("Frame", {
			ref = props.move_ref,
			Name = "move",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = true,
			Selectable = true,
			ZIndex = 20,
		}, {
			stroke = create_element("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.6 }),
			drag = create_element(editor_drag_detector, {
				on_start = props.on_drag_start,
				on_move = props.on_drag_move,
				on_finish = props.on_drag_finish,
			}),
		}),
		handles = create_element(React.Fragment, {}, handles),
		Delete = create_element(action_button, {
			button_ref = props.delete_ref,
			anchor = 1,
			side = "left",
			colour = Color3.new(1, 84 / 255, 84 / 255),
			image = "rbxassetid://78109412963567",
			on_activate = props.on_delete,
		}),
		Settings = create_element(action_button, {
			button_ref = props.settings_ref,
			anchor = 0,
			side = "right",
			image = "rbxassetid://104330757164550",
			on_activate = props.on_settings,
		}),
	})
end

return widget_bounds
