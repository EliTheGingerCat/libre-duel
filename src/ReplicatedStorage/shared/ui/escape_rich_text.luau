const RICH_TEXT_ESCAPES = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
}

-- keeps player written text from being read as rich text tags
const function escape_rich_text(text: string): string
	return (string.gsub(text, "[&<>\"']", RICH_TEXT_ESCAPES))
end

return escape_rich_text
