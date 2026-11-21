const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)

-- rich text is on on purpose, bios and guild descriptions are allowed to use it
const function rich_text_description(props: { text: string, layout_order: number? })
	return React.createElement("TextLabel", {
		Name = "description",
		LayoutOrder = props.layout_order or 1,
		Size = UDim2.new(1, 0, 0, 48),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		FontFace = FONTS.regular,
		RichText = true,
		Text = props.text,
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextWrapped = true,
	})
end

return rich_text_description
