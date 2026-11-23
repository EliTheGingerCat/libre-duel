const format_number = require(script.Parent.format_number)

-- "1.42", or just the numerator when there is nothing to divide by yet
const function format_ratio(numerator: number, denominator: number): string
	if denominator == 0 then
		return format_number(numerator)
	end
	return string.format("%.2f", numerator / denominator)
end

return format_ratio
