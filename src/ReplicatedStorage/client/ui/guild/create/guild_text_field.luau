const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const format_guild_number = require(script.Parent.Parent.format.format_guild_number)
const surface = require(script.Parent.Parent.Parent.visuals.controls.surface)

const create_element = React.createElement

const REQUIRED_MARK = "<font color='rgb(255, 200, 84)'>*</font>"
const LABEL_SIZE = 24
const SINGLE_LINE_HEIGHT = 50
const SINGLE_LINE_TEXT_SIZE = 36
const MULTI_LINE_TEXT_SIZE = 24

-- utf8.len is nil for broken utf8, which the server rejects anyway
const function count_characters(text: string): number
	return utf8.len(text) or #text
end

const function truncate_to(text: string, max_length: number): string
	if count_characters(text) <= max_length then
		return text
	end
	const cut_at = utf8.offset(text, max_length + 1)
	return if cut_at then string.sub(text, 1, cut_at - 1) else text
end

const function create_label(text: string, alignment: Enum.TextXAlignment)
	return create_element("TextLabel", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		FontFace = FONTS.semi_bold,
		RichText = true,
		Text = text,
		TextSize = LABEL_SIZE,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = alignment,
	})
end

-- label with a live character counter above an input, like the guild create reference
-- label_note is shown greyed after the label, e.g. "(supports rich text)"
const function guild_text_field(props: {
	label: string,
	label_note: string?,
	required: boolean?,
	placeholder: string,
	text: string,
	max_length: number,
	multi_line: boolean?,
	height: number?,
	layout_order: number,
	on_changed: (string) -> (),
})
	const function changed(box: TextBox): ()
		const truncated = truncate_to(box.Text, props.max_length)
		if truncated ~= box.Text then
			box.Text = truncated
			return
		end
		props.on_changed(truncated)
	end
	local label = props.label
	if props.required then
		label ..= REQUIRED_MARK
	end
	if props.label_note then
		label ..= ` <font color='rgb(200, 200, 200)'>{props.label_note}</font>`
	end
	const multi_line = props.multi_line == true
	return create_element("Frame", {
		Name = props.label,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		labels = create_element("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			title = create_label(label, Enum.TextXAlignment.Left),
			counter = create_label(
				`{format_guild_number(count_characters(props.text))}/{format_guild_number(props.max_length)}`,
				Enum.TextXAlignment.Right
			),
		}),
		box = create_element("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, props.height or SINGLE_LINE_HEIGHT),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
		}, {
			surface = create_element(surface, { radius = 16 }),
			input = create_element("TextBox", {
				Name = "input",
				Position = UDim2.fromOffset(20, 0),
				Size = UDim2.new(1, -34, 1, 0),
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				MultiLine = multi_line,
				TextWrapped = multi_line,
				FontFace = FONTS.regular,
				PlaceholderColor3 = Color3.fromRGB(129, 129, 129),
				PlaceholderText = props.placeholder,
				Text = props.text,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = if multi_line then MULTI_LINE_TEXT_SIZE else SINGLE_LINE_TEXT_SIZE,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = if multi_line then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center,
				[React.Change.Text] = changed,
			}, {
				padding = multi_line
					and create_element("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }),
			}),
		}),
	})
end

return guild_text_field
