const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

const fetch_guild_info_remote = ReplicatedStorage.remotes.guild.fetch_guild_info

-- yields, nil when the server couldn't be reached or the guild doesn't exist
const function fetch_guild_info(guild_id: string): guild_snapshot_types.guild_snapshot?
	const ok, snapshot = pcall(fetch_guild_info_remote.InvokeServer, fetch_guild_info_remote, guild_id)
	if not ok or typeof(snapshot) ~= "table" then
		return nil
	end
	return snapshot :: guild_snapshot_types.guild_snapshot
end

return fetch_guild_info
