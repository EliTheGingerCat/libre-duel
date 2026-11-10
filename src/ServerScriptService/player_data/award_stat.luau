const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const registry = require(ReplicatedStorage.shared.entity.registry)
const player_store = require(script.Parent.player_store)

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

-- Bots have no saved data, so awarding one does nothing.
const function award_stat(entity: registry.entity, mode: GAME_STATS.mode, stat: GAME_STATS.stat, increment: number?)
	const player = registry.get_player(entity)
	if player == nil then
		return
	end
	const amount = increment or 1
	drop.update(player_store, tostring(player.UserId), function(data)
		const new = table.clone(data)
		const new_stats = table.clone(new.stats)
		-- Data saved before a mode existed has no entry for it.
		const mode_stats: GAME_STATS.stats = table.clone(new_stats[mode] or GAME_STATS[mode])
		mode_stats[stat] += amount
		new_stats[mode] = mode_stats
		new.stats = new_stats
		return new
	end)
end

return award_stat
