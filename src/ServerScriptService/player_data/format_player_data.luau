const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const format_duration = require(ServerScriptService.util.format_duration)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)

-- one line per entry, for showing saved data to a human
const function format_player_data(data: player_schema.player_data): { string }
	const lines = {
		`first joined: {if data.first_joined == 0 then "never" else os.date("!%Y-%m-%d %H:%M UTC", data.first_joined)}`,
		-- saves that never went through a session can be missing migrated fields
		`playtime: {format_duration(
			data.playtime or 0
		)}`,
		`total clicks: {data.total_clicks}`,
	}
	for _, definition in MODE_DEFINITIONS do
		const stats = data.stats[definition.id]
		if stats ~= nil then
			table.insert(
				lines,
				`{definition.id}: {stats.wins} wins, {stats.losses} losses, {stats.kills} kills, {stats.deaths} deaths, {stats.goals} goals`
			)
		end
	end
	return lines
end

return format_player_data
