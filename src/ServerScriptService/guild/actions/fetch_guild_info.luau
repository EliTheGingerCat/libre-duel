const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const build_guild_snapshot = require(ServerScriptService.guild.replication.build_guild_snapshot)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const read_guild_data = require(ServerScriptService.guild.data.read_guild_data)

-- for looking at a guild you're not in, members also get the private parts
const function fetch_guild_info(player: Player, guild_id: string): guild_snapshot_types.guild_snapshot?
	const data = read_guild_data(guild_id)
	if data == nil then
		return nil
	end
	return build_guild_snapshot(data, data.members[tostring(player.UserId)] ~= nil)
end

return fetch_guild_info
