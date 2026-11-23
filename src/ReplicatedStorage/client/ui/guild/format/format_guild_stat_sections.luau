const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const format_guild_game_stats = require(script.Parent.format_guild_game_stats)
const format_guild_mode_title = require(script.Parent.format_guild_mode_title)
const format_guild_number = require(script.Parent.format_guild_number)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const profile_types = require(script.Parent.Parent.Parent.profile_card.profile_types)
const sum_guild_mode_stats = require(script.Parent.sum_guild_mode_stats)

const SECONDS_PER_HOUR = 3600

const function format_hours(seconds: number): string
	return `{format_guild_number(seconds // SECONDS_PER_HOUR)}h`
end

-- the guild as a whole first, then one section per mode in MODE_DEFINITIONS order
-- playtime isn't tracked per mode, so it only shows up in the overall part
const function format_guild_stat_sections(snapshot: guild_snapshot_types.guild_snapshot): { guild_types.stat_section }
	const overall = format_guild_game_stats(sum_guild_mode_stats(snapshot.totals))
	const sections: { guild_types.stat_section } = {
		{ id = "matches", title = "Matches", stats = overall.matches },
		{ id = "combat", title = "Combat", stats = overall.combat },
		{
			id = "playtime",
			title = "Playtime",
			stats = {
				{ id = "playtime", label = "Total", value = format_hours(snapshot.total_playtime) },
			},
		},
	}
	for _, definition in MODE_DEFINITIONS do
		const mode = format_guild_game_stats(snapshot.totals[definition.id] or GAME_STATS[definition.id])
		const stats: { profile_types.highlight_stat } = table.clone(mode.matches)
		table.move(mode.combat, 1, #mode.combat, #stats + 1, stats)
		table.insert(sections, {
			id = definition.id :: string,
			title = format_guild_mode_title(definition),
			title_colour = definition.colour,
			stats = stats,
		})
	end
	return sections
end

return format_guild_stat_sections
