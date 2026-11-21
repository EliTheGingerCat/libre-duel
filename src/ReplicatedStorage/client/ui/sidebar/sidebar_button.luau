const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.visuals.animated_button)
const button_motion = require(script.Parent.Parent.visuals.button_motion)
const gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
const sidebar_types = require(script.Parent.sidebar_types)
const use_ui_motion = require(script.Parent.Parent.visuals.use_ui_motion)

const function transparency(value: number): number
	return 1 - 0.5 * value
end

const function sidebar_button(props: {
	entry: sidebar_types.entry,
	selected: boolean,
	on_selected: (string) -> (),
})
	const hovered, set_hovered = React.useState(false)
	const focused, set_focused = React.useState(false)
	const motion = use_ui_motion(if props.selected then 1 elseif hovered or focused then 0.45 else 0)
	const colour = props.entry.colour or Color3.new(1, 1, 1)
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	const function focus(): ()
		set_focused(true)
	end
	const function blur(): ()
		set_focused(false)
	end
	const function activate(): ()
		props.on_selected(props.entry.id)
	end
	return React.createElement(animated_button, {
		Name = props.entry.id,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Color3.new(127 / 255, 127 / 255, 127 / 255),
		BackgroundTransparency = motion:map(transparency),
		Text = "",
		[React.Event.Activated] = activate,
		[React.Event.MouseEnter] = enter,
		[React.Event.MouseLeave] = leave,
		[React.Event.SelectionGained] = focus,
		[React.Event.SelectionLost] = blur,
	}, {
		motion = React.createElement(button_motion),
		corner = React.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }),
		stroke = props.selected and React.createElement(gradient_stroke),
		icon = React.createElement("ImageLabel", {
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.fromOffset(38, 38),
			BackgroundTransparency = 1,
			Image = props.entry.icon,
			ImageColor3 = colour,
		}),
		label = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 64, 0.5, 0),
			Size = UDim2.new(1, -64, 0.64, 0),
			BackgroundTransparency = 1,
			Text = props.entry.text,
			TextSize = 32,
			TextScaled = true,
			TextColor3 = colour,
			FontFace = FONTS.regular,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return sidebar_button
