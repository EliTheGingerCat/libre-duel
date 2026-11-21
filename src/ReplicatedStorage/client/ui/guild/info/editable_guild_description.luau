const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)

const create_element = React.createElement

const EMPTY_HINT = "Click to write a description. Rich text works here."
const HINT_COLOUR = Color3.fromRGB(150, 150, 150)

const function truncate_to(text: string, max_length: number): string
	if (utf8.len(text) or #text) <= max_length then
		return text
	end
	const cut_at = utf8.offset(text, max_length + 1)
	return if cut_at then string.sub(text, 1, cut_at - 1) else text
end

-- shows the rendered rich text, and the raw text once focused so tags can be edited
-- saves when the viewer clicks away, enter makes a new line since descriptions can have several
const function editable_guild_description(props: {
	text: string,
	max_length: number,
	layout_order: number?,
	on_changed: (text: string) -> (),
})
	const focused, set_focused = React.useState(false)
	const function limit_length(box: TextBox): ()
		const truncated = truncate_to(box.Text, props.max_length)
		if truncated ~= box.Text then
			box.Text = truncated
		end
	end
	const function focus(): ()
		set_focused(true)
	end
	const function submit(box: TextBox): ()
		set_focused(false)
		if box.Text ~= props.text then
			props.on_changed(box.Text)
		end
	end
	return create_element("TextBox", {
		Name = "description",
		LayoutOrder = props.layout_order or 1,
		Size = UDim2.new(1, 0, 0, 48),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		MultiLine = true,
		FontFace = FONTS.regular,
		-- off while focused so the tags show up as text instead of being rendered
		RichText = not focused,
		Text = props.text,
		PlaceholderText = EMPTY_HINT,
		PlaceholderColor3 = HINT_COLOUR,
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextWrapped = true,
		[React.Change.Text] = limit_length,
		[React.Event.Focused] = focus,
		[React.Event.FocusLost] = submit,
	})
end

return editable_guild_description
