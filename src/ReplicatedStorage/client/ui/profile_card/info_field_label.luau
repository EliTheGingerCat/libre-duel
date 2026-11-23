const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const format_labelled_value = require(script.Parent.format_labelled_value)
const profile_types = require(script.Parent.profile_types)

const create_element = React.createElement
const LINK_COLOUR = COLOURS.sky_300

-- a label with its value under it, the value turns into a link when the field has on_activated
const function info_field_label(props: { field: profile_types.info_field, layout_order: number })
	const field = props.field
	const hovered, set_hovered = React.useState(false)
	const is_link = field.on_activated ~= nil
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	return create_element(if is_link then "TextButton" else "TextLabel", {
		Name = field.id,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(0.33, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		AutoButtonColor = if is_link then false else nil,
		FontFace = FONTS.regular,
		RichText = true,
		Text = format_labelled_value(
			field.label,
			field.value,
			if is_link then LINK_COLOUR else nil,
			is_link and hovered
		),
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		[React.Event.Activated] = field.on_activated,
		[React.Event.MouseEnter] = if is_link then enter else nil,
		[React.Event.MouseLeave] = if is_link then leave else nil,
	})
end

return info_field_label
