const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = 3600

-- "2h 5m", or "5m" under an hour
const function format_duration(seconds: number): string
	const hours = seconds // SECONDS_PER_HOUR
	const minutes = seconds % SECONDS_PER_HOUR // SECONDS_PER_MINUTE
	return if hours > 0 then `{hours}h {minutes}m` else `{minutes}m`
end

return format_duration
