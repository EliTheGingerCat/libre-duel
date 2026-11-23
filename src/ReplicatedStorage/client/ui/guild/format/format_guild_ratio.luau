const format_guild_number = require(script.Parent.format_guild_number)

-- "1.42", or just the numerator when there is nothing to divide by yet
const function format_guild_ratio(numerator: number, denominator: number): string
	if denominator == 0 then
		return format_guild_number(numerator)
	end
	return string.format("%.2f", numerator / denominator)
end

return format_guild_ratio
