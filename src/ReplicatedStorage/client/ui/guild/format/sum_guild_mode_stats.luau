const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)

-- every mode added together, modes missing from the table count as zero
const function sum_guild_mode_stats(modes: GAME_STATS.modes): GAME_STATS.stats
	const total: GAME_STATS.stats = { wins = 0, goals = 0, kills = 0, losses = 0, deaths = 0 }
	for _, definition in MODE_DEFINITIONS do
		const mode_stats = modes[definition.id] or GAME_STATS[definition.id]
		total.wins += mode_stats.wins
		total.goals += mode_stats.goals
		total.kills += mode_stats.kills
		total.losses += mode_stats.losses
		total.deaths += mode_stats.deaths
	end
	return total
end

return sum_guild_mode_stats
