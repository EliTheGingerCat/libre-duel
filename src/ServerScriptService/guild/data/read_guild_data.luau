const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(script.Parent.schema.guild_schema)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(script.Parent.guild_store)

-- uses this server's session when there is one, otherwise yields for a datastore read
-- nil when the read fails or the guild doesn't exist
const function read_guild_data(guild_id: string): guild_schema.guild_data?
	if guild_id == "" then
		return nil
	end
	local data: guild_schema.guild_data? = nil
	if guild_session_refcount.is_active(guild_id) then
		data = drop.view(guild_store, guild_id)
	else
		const ok, result = pcall(drop.viewasync, guild_store, guild_id)
		data = if ok then result else nil
	end
	if data == nil or data.id == "" or data.deleted then
		return nil
	end
	return data
end

return read_guild_data
