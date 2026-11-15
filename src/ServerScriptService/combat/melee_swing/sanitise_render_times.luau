const MELEE_SWING_CONSTANTS = require(script.Parent.MELEE_SWING_CONSTANTS)

export type render_times = { [Player]: number }

const function is_finite_number(value: unknown): boolean
	return type(value) == "number" and value == value and math.abs(value) ~= math.huge
end

-- remotes drop Instance keys, so the client sends an array of entries and it gets turned back into a map here
const function sanitise_render_times(raw_entries: unknown): render_times
	const render_times: render_times = {}
	if type(raw_entries) ~= "table" then
		return render_times
	end

	const entries = raw_entries :: { unknown }
	for index = 1, MELEE_SWING_CONSTANTS.maximum_render_time_entries do
		const raw_entry = entries[index]
		if type(raw_entry) ~= "table" then
			break
		end
		const entry = raw_entry :: { [string]: unknown }
		const player = entry.player
		const time = entry.time
		if typeof(player) == "Instance" and player:IsA("Player") and is_finite_number(time) then
			render_times[player] = time :: number
		end
	end

	return render_times
end

return sanitise_render_times
