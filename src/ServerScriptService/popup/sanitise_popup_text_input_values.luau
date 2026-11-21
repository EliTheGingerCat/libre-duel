const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_TEXT_INPUT_MAX_LENGTH = require(ReplicatedStorage.shared.popup.POPUP_TEXT_INPUT_MAX_LENGTH)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)

const function sanitise_text(text: unknown): string
	if type(text) ~= "string" or utf8.len(text) == nil then
		return ""
	end
	-- cut by characters, not bytes, so multibyte characters are not split
	const cut_offset = utf8.offset(text, POPUP_TEXT_INPUT_MAX_LENGTH + 1)
	if cut_offset == nil then
		return text
	end
	return string.sub(text, 1, cut_offset - 1)
end

-- only keeps the ids the server asked for, so the callback never sees anything it did not expect
const function sanitise_popup_text_input_values(
	text_input_values: unknown,
	text_input_ids: { string }
): popup_types.popup_text_input_values
	const received_values = if type(text_input_values) == "table"
		then text_input_values :: { [unknown]: unknown }
		else {}
	const sanitised_values = {}
	for _, text_input_id in text_input_ids do
		sanitised_values[text_input_id] = sanitise_text(received_values[text_input_id])
	end
	return sanitised_values
end

return sanitise_popup_text_input_values
