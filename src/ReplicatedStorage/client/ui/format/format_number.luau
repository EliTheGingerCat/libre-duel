-- "195291" -> "195,291"
const function format_number(value: number): string
	const digits = tostring(math.floor(value))
	const formatted = string.reverse((string.gsub(string.reverse(digits), "(%d%d%d)", "%1,")))
	return (string.gsub(formatted, "^(-?),", "%1"))
end

return format_number
