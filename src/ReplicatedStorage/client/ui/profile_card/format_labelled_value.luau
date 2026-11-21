const ReplicatedStorage = game:GetService("ReplicatedStorage")

const escape_rich_text = require(ReplicatedStorage.shared.ui.escape_rich_text)

const VALUE_COLOUR = "rgb(200, 200, 200)"
const VALUE_TEXT_SIZE = 20

-- a white label with a smaller grey value under it, used by info fields and stats
const function format_labelled_value(label: string, value: string): string
	return string.format(
		"%s\n<font color='%s'><font size=\"%d\">%s</font></font>",
		escape_rich_text(label),
		VALUE_COLOUR,
		VALUE_TEXT_SIZE,
		escape_rich_text(value)
	)
end

return format_labelled_value
