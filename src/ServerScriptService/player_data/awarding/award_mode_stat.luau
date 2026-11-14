const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const registry = require(ReplicatedStorage.shared.entity.registry)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const update_player_data = require(script.Parent.update_player_data)

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

const function award_mode_stat(
	entity: registry.entity,
	mode: GAME_STATS.mode,
	stat: GAME_STATS.stat,
	increment: number?
): ()
	const amount = increment or 1
	const function add_to_mode_stat(data: player_schema.player_data): player_schema.player_data
		const new_data = table.clone(data)
		const new_stats = table.clone(new_data.stats)
		-- data saved before a mode existed has no entry for it
		const mode_stats: GAME_STATS.stats = table.clone(new_stats[mode] or GAME_STATS[mode])
		mode_stats[stat] += amount
		new_stats[mode] = mode_stats
		new_data.stats = new_stats
		return new_data
	end
	update_player_data(entity, add_to_mode_stat)
end

return award_mode_stat
