const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

const SECONDS_PER_DAY = 86400

-- one point per UTC day, later calls on the same day move that day's point to the newest rank
-- only call it for players with an active session on this server
const function record_player_rank_history(player: Player, rank: number): ()
	const today = os.time() // SECONDS_PER_DAY
	const function append_point(data: player_schema.player_data): player_schema.player_data
		const old_history = data.rank_history or {}
		const last_point = old_history[#old_history]
		const is_today = last_point ~= nil and last_point.time // SECONDS_PER_DAY == today
		if is_today and last_point.rank == rank then
			return data
		end
		const new_data = table.clone(data)
		const history = table.clone(old_history)
		if is_today then
			history[#history] = { time = last_point.time, rank = rank }
		else
			table.insert(history, { time = os.time(), rank = rank })
		end
		while #history > PLAYER_PROFILE_LIMITS.MAX_RANK_HISTORY_POINTS do
			table.remove(history, 1)
		end
		new_data.rank_history = history
		return new_data
	end
	drop.update(player_store, tostring(player.UserId), append_point)
end

return record_player_rank_history
