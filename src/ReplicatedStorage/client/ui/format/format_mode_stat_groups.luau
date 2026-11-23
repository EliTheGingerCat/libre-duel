const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const format_mode_title = require(script.Parent.format_mode_title)
const format_number = require(script.Parent.format_number)
const format_ratio = require(script.Parent.format_ratio)
const profile_types = require(script.Parent.Parent.profile_card.profile_types)

const SECONDS_PER_HOUR = 3600

-- the stats a member earned while in the guild, an overall group then one per mode
const function format_mode_stat_groups(stats: GAME_STATS.modes, playtime: number): { profile_types.stat_group }
	local total_wins = 0
	local total_losses = 0
	const groups: { profile_types.stat_group } = {}
	for _, definition in MODE_DEFINITIONS do
		const mode_stats = stats[definition.id] or GAME_STATS[definition.id]
		total_wins += mode_stats.wins
		total_losses += mode_stats.losses
		table.insert(groups, {
			id = definition.id :: string,
			title = format_mode_title(definition),
			stats = {
				{ id = "wins", icon = "🏆", label = "Wins", value = format_number(mode_stats.wins) },
				{ id = "kills", icon = "⚔️", label = "Kills", value = format_number(mode_stats.kills) },
				{ id = "losses", icon = "💀", label = "Losses", value = format_number(mode_stats.losses) },
				{
					id = "win_loss_ratio",
					icon = "➗",
					label = "W/LR",
					value = format_ratio(mode_stats.wins, mode_stats.losses),
				},
			},
		})
	end
	table.insert(groups, 1, {
		id = "overall",
		title = "Overall",
		stats = {
			{
				id = "playtime",
				icon = "🕔",
				label = "Playtime",
				value = `{format_number(playtime // SECONDS_PER_HOUR)} hours`,
			},
			{ id = "wins", icon = "🏆", label = "Wins", value = format_number(total_wins) },
			{
				id = "win_loss_ratio",
				icon = "➗",
				label = "W/LR",
				value = format_ratio(total_wins, total_losses),
			},
		},
	})
	return groups
end

return format_mode_stat_groups
