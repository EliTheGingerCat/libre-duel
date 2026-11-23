const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const format_number = require(script.Parent.format_number)
const format_percent = require(script.Parent.format_percent)
const format_ratio = require(script.Parent.format_ratio)
const profile_types = require(script.Parent.Parent.profile_card.profile_types)

export type game_stats = {
	matches: { profile_types.highlight_stat },
	combat: { profile_types.highlight_stat },
}

-- the same numbers for the whole guild and for each mode, so both read the same way
const function format_game_stats(stats: GAME_STATS.stats): game_stats
	const games = stats.wins + stats.losses
	return {
		matches = {
			{ id = "games", label = "Games played", value = format_number(games) },
			{ id = "wins", label = "Wins", value = format_number(stats.wins) },
			{ id = "losses", label = "Losses", value = format_number(stats.losses) },
			{
				id = "win_rate",
				label = "Win rate",
				value = if games > 0 then format_percent(stats.wins / games) else "-",
			},
			{ id = "win_loss_ratio", label = "W/LR", value = format_ratio(stats.wins, stats.losses) },
		},
		combat = {
			{ id = "kills", label = "Kills", value = format_number(stats.kills) },
			{ id = "deaths", label = "Deaths", value = format_number(stats.deaths) },
			{ id = "kill_death_ratio", label = "K/D", value = format_ratio(stats.kills, stats.deaths) },
			{ id = "goals", label = "Goals", value = format_number(stats.goals) },
		},
	}
end

return format_game_stats
