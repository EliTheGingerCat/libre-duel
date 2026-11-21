const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_guild_ids = require(ServerScriptService.guild.session.player_guild_ids)

export type player_guild = {
	id: string,
	data: guild_schema.guild_data,
	member: guild_schema.guild_member,
	is_owner: boolean,
}

-- never yields, reads the cached guild of a confirmed member on this server
const function get_player_guild(player: Player): player_guild?
	const guild_id = player_guild_ids[player]
	if guild_id == nil or not guild_session_refcount.is_active(guild_id) then
		return nil
	end
	const data = drop.view(guild_store, guild_id)
	const member = data.members[tostring(player.UserId)]
	if data.deleted or member == nil then
		return nil
	end
	return { id = guild_id, data = data, member = member, is_owner = data.owner_id == player.UserId }
end

return get_player_guild
