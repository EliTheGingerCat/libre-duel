type unit = { seconds: number, name: string }

-- biggest first
const UNITS: { unit } = {
	{ seconds = 31536000, name = "year" },
	{ seconds = 2592000, name = "month" },
	{ seconds = 604800, name = "week" },
	{ seconds = 86400, name = "day" },
	{ seconds = 3600, name = "hour" },
	{ seconds = 60, name = "minute" },
}

-- "5 minutes ago", "1 day ago", or "Just now" for anything under a minute
const function format_time_ago(unix_time: number, now: number): string
	const elapsed = math.max(0, now - unix_time)
	for _, time_unit in UNITS do
		if elapsed >= time_unit.seconds then
			const amount = elapsed // time_unit.seconds
			return `{amount} {time_unit.name}{if amount == 1 then "" else "s"} ago`
		end
	end
	return "Just now"
end

return format_time_ago
