-- 0.625 -> "63%"
const function format_percent(fraction: number): string
	return `{math.round(fraction * 100)}%`
end

return format_percent
