local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.gradient_stroke)
local use_viewport_scale = require(script.Parent.use_viewport_scale)

local create_element = React.createElement

export type props = {
	name: string,
	title: string,
	size: Vector2?,
	enabled: boolean,
	display_order: number?,
	on_close: () -> (),
	children: unknown?,
}

local function menu_window(props: props)
	local size = props.size or Vector2.new(1200, 720)
	return create_element("ScreenGui", {
		Name = props.name,
		Enabled = props.enabled,
		ResetOnSpawn = false,
		DisplayOrder = props.display_order or 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		background = create_element("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			Modal = true,
			ZIndex = 0,
			[React.Event.Activated] = props.on_close,
		}),
		window = create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size.X, size.Y),
			BackgroundColor3 = Color3.new(35 / 255, 35 / 255, 35 / 255),
			BorderSizePixel = 0,
			Active = true,
		}, {
			scale = create_element("UIScale", { Scale = math.min(1, use_viewport_scale()) }),
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, 65) }),
			stroke = create_element(gradient_stroke),
			title = create_element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, -100, 0, 48),
				BackgroundTransparency = 1,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
				Text = props.title,
				TextSize = 30,
				TextColor3 = Color3.new(1, 1, 1),
				ZIndex = 2,
			}),
			close_button = create_element("ImageButton", {
				Position = UDim2.new(1, -80, 0, 5),
				Size = UDim2.fromOffset(42, 42),
				BackgroundTransparency = 1,
				Image = "rbxassetid://72160170469319",
				ZIndex = 2,
				[React.Event.Activated] = props.on_close,
			}),
			body = create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -10, 1, -10),
				BackgroundColor3 = Color3.new(47 / 255, 47 / 255, 47 / 255),
				BorderSizePixel = 0,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(0, 60) }),
				stroke = create_element(gradient_stroke),
				content = create_element(React.Fragment, {}, props.children),
			}),
		}),
	})
end

return menu_window
