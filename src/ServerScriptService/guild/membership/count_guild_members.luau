const ServerScriptService = game:GetService("ServerScriptService")

const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)

const function count_guild_members(data: guild_schema.guild_data): number
	local count = 0
	for _ in data.members do
		count += 1
	end
	return count
end

return count_guild_members
