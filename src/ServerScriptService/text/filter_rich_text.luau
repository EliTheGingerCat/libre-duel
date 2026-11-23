const filter_text = require(script.Parent.filter_text)

type piece = { is_tag: boolean, text: string }

const TAG_PATTERN = "<[^<>]*>"

-- "hey <b>you</b>" -> text "hey ", tag "<b>", text "you", tag "</b>"
const function split_into_pieces(text: string): { piece }
	const pieces: { piece } = {}
	local position = 1
	while true do
		const tag_start, tag_end = string.find(text, TAG_PATTERN, position)
		if tag_start == nil or tag_end == nil then
			break
		end
		if tag_start > position then
			table.insert(pieces, { is_tag = false, text = string.sub(text, position, tag_start - 1) })
		end
		table.insert(pieces, { is_tag = true, text = string.sub(text, tag_start, tag_end) })
		position = tag_end + 1
	end
	if position <= #text then
		table.insert(pieces, { is_tag = false, text = string.sub(text, position) })
	end
	return pieces
end

-- yields, nil when filtering failed, in which case the text must not be shown to anyone
-- only the visible text goes through the filter, otherwise it hashes the tags and breaks the formatting
-- the text is filtered as one string so splitting a word with tags doesn't get it past the filter
-- the filter swaps each censored character for one #, so the filtered text lines up with the original character for character
-- if it ever doesn't, the tags are dropped instead of being put back in the wrong places
const function filter_rich_text(author: Player, text: string): string?
	const pieces = split_into_pieces(text)
	const plain_parts = {}
	for _, piece in pieces do
		if not piece.is_tag then
			table.insert(plain_parts, piece.text)
		end
	end
	const plain = table.concat(plain_parts)
	const filtered = filter_text(author, plain)
	if filtered == nil then
		return nil
	end
	if filtered == plain then
		return text
	end
	const plain_length = utf8.len(plain)
	if plain_length == nil or plain_length ~= utf8.len(filtered) then
		return filtered
	end
	const rebuilt = {}
	local filtered_offset = 1
	for _, piece in pieces do
		if piece.is_tag then
			table.insert(rebuilt, piece.text)
		else
			const piece_length = utf8.len(piece.text) :: number
			const next_offset = utf8.offset(filtered, piece_length + 1, filtered_offset) :: number
			table.insert(rebuilt, string.sub(filtered, filtered_offset, next_offset - 1))
			filtered_offset = next_offset
		end
	end
	return table.concat(rebuilt)
end

return filter_rich_text
