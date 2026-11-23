const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const format_game_stats = require(script.Parent.format_game_stats)
const format_mode_title = require(script.Parent.format_mode_title)
const format_number = require(script.Parent.format_number)
const profile_types = require(script.Parent.Parent.profile_card.profile_types)
const sum_mode_stats = require(script.Parent.sum_mode_stats)

const SECONDS_PER_HOUR = 3600

const function format_hours(seconds: number): string
	return `{format_number(seconds // SECONDS_PER_HOUR)}h`
end

-- everything added up first, then one section per mode in MODE_DEFINITIONS order
-- playtime isn't tracked per mode, so it only shows up in the overall part
const function format_stat_sections(modes: GAME_STATS.modes, playtime: number): { profile_types.stat_section }
	const overall = format_game_stats(sum_mode_stats(modes))
	const sections: { profile_types.stat_section } = {
		{ id = "matches", title = "Matches", stats = overall.matches },
		{ id = "combat", title = "Combat", stats = overall.combat },
		{
			id = "playtime",
			title = "Playtime",
			stats = {
				{ id = "playtime", label = "Total", value = format_hours(playtime) },
			},
		},
	}
	for _, definition in MODE_DEFINITIONS do
		const mode = format_game_stats(modes[definition.id] or GAME_STATS[definition.id])
		const stats: { profile_types.highlight_stat } = table.clone(mode.matches)
		table.move(mode.combat, 1, #mode.combat, #stats + 1, stats)
		table.insert(sections, {
			id = definition.id :: string,
			title = format_mode_title(definition),
			title_colour = definition.colour,
			stats = stats,
		})
	end
	return sections
end

return format_stat_sections
