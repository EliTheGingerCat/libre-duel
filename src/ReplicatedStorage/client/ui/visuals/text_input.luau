local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local surface = require(script.Parent.controls.surface)

const function text_input(props: {
	text: string?,
	placeholder: string?,
	icon: string?,
	on_changed: ((string) -> ())?,
})
	const function changed(box: TextBox): ()
		if props.on_changed then
			props.on_changed(box.Text)
		end
	end
	local inset = if props.icon then 54 else 20
	return React.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
	}, {
		surface = React.createElement(surface),
		icon = props.icon and React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 10),
			Size = UDim2.fromOffset(30, 30),
			Image = props.icon,
		}),
		input = React.createElement("TextBox", {
			Name = "input",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(inset, 0),
			Size = UDim2.new(1, -inset - 14, 1, 0),
			ClearTextOnFocus = false,
			FontFace = FONTS.regular,
			PlaceholderColor3 = Color3.new(129 / 255, 129 / 255, 129 / 255),
			PlaceholderText = props.placeholder or "Enter text...",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 36,
			Text = props.text or "",
			TextXAlignment = Enum.TextXAlignment.Left,
			[React.Change.Text] = changed,
		}),
	})
end

return text_input
