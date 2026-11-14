-- "1 player", "3 players"
const function format_count(count: number, noun: string): string
	return `{count} {noun}{if count == 1 then "" else "s"}`
end

return format_count
