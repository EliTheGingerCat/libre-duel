-- 0.625 -> "63%"
const function format_guild_percent(fraction: number): string
	return `{math.round(fraction * 100)}%`
end

return format_guild_percent
