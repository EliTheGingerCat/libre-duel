export type render_times = { [Player]: number }

export type render_time_packet_entry = { player: Player?, time: number }

const function is_finite_number(value: number): boolean
	return value == value and math.abs(value) ~= math.huge
end

-- remotes drop Instance keys, so the client sends an array of entries and it gets turned back into a map here
-- zap already capped the length and checked the types, but it lets NaN and inf through
const function sanitise_render_times(entries: { render_time_packet_entry }): render_times
	const render_times: render_times = {}
	for _, entry in entries do
		if entry.player ~= nil and is_finite_number(entry.time) then
			render_times[entry.player] = entry.time
		end
	end
	return render_times
end

return sanitise_render_times
