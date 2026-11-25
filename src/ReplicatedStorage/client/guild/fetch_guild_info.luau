const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- yields, nil when rate limited or the guild doesn't exist
const function fetch_guild_info(guild_id: string): guild_snapshot_types.guild_snapshot?
	return zap_client_network.fetch_guild_info.call(guild_id)
end

return fetch_guild_info
