-- "Nov 21, 2026", or "November 21, 2026" when long, in the viewer's own time zone
const function format_date(unix_time: number, long: boolean?): string
	return os.date(if long then "%B %d, %Y" else "%b %d, %Y", unix_time)
end

return format_date
