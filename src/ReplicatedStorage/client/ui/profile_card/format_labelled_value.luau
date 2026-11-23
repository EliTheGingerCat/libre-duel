const ReplicatedStorage = game:GetService("ReplicatedStorage")

const escape_rich_text = require(ReplicatedStorage.shared.ui.escape_rich_text)

const DEFAULT_VALUE_COLOUR = Color3.fromRGB(200, 200, 200)
const VALUE_TEXT_SIZE = 20

-- a white label with a smaller value under it, used by info fields and stats
const function format_labelled_value(
	label: string,
	value: string,
	value_colour: Color3?,
	underline_value: boolean?
): string
	const escaped_value = escape_rich_text(value)
	return string.format(
		"%s\n<font color='#%s'><font size=\"%d\">%s</font></font>",
		escape_rich_text(label),
		(value_colour or DEFAULT_VALUE_COLOUR):ToHex(),
		VALUE_TEXT_SIZE,
		if underline_value then `<u>{escaped_value}</u>` else escaped_value
	)
end

return format_labelled_value
