const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)

const SECONDS_PER_DAY = 86400

-- one point per UTC day, every server with the guild's session may call this but only the first one each day adds a point
const function record_guild_rank_history(guild_id: string, rank: number): ()
	const today = os.time() // SECONDS_PER_DAY
	const function append_point(data: guild_schema.guild_data): guild_schema.guild_data
		const last_point = data.rank_history[#data.rank_history]
		if data.deleted or (last_point and last_point.time // SECONDS_PER_DAY == today) then
			return data
		end
		const new_data = table.clone(data)
		const history = table.clone(data.rank_history)
		table.insert(history, { time = today * SECONDS_PER_DAY, rank = rank })
		while #history > GUILD_LIMITS.MAX_RANK_HISTORY_POINTS do
			table.remove(history, 1)
		end
		new_data.rank_history = history
		return new_data
	end
	drop.update(guild_store, guild_id, append_point)
end

return record_guild_rank_history
