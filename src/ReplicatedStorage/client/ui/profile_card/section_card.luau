const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const SECTION_CARD_LAYOUT = require(script.Parent.SECTION_CARD_LAYOUT)

const create_element = React.createElement

export type props = {
	name: string?,
	title: string,
	title_colour: Color3?,
	layout_order: number?,
	padding_bottom: number?,
	-- a fixed size instead of growing with the content, for cards that scroll their own content
	size: UDim2?,
	-- children are laid out in a wrapping row under the title, give them a LayoutOrder of 1 or more
	children: unknown?,
}

const function section_card(props: props)
	return create_element("Frame", {
		Name = props.name,
		LayoutOrder = props.layout_order,
		Size = props.size or UDim2.fromScale(1, 0),
		AutomaticSize = if props.size then Enum.AutomaticSize.None else Enum.AutomaticSize.Y,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, SECTION_CARD_LAYOUT.corner_radius) }),
		padding = create_element("UIPadding", {
			PaddingTop = UDim.new(0, SECTION_CARD_LAYOUT.padding_top),
			PaddingLeft = UDim.new(0, SECTION_CARD_LAYOUT.padding_left),
			PaddingRight = UDim.new(0, SECTION_CARD_LAYOUT.padding_right),
			PaddingBottom = UDim.new(0, props.padding_bottom or SECTION_CARD_LAYOUT.padding_bottom),
		}),
		layout = create_element("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		title = create_element("TextLabel", {
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, SECTION_CARD_LAYOUT.title_height),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = FONTS.semi_bold,
			Text = props.title,
			TextSize = 32,
			TextColor3 = props.title_colour or Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		content = create_element(React.Fragment, nil, props.children),
	})
end

return section_card
