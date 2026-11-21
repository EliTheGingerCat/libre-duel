const ServerScriptService = game:GetService("ServerScriptService")

const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)

-- shared by leaving, kicking and banning, the removed player's hint gets cleared by sync_player_guild wherever they are
-- totals keep what the member earned, only their own entry goes
const function remove_guild_member_async(guild_id: string, user_id: number, ban: boolean): boolean
	const key = tostring(user_id)
	const function remove_member(data: guild_schema.guild_data): guild_schema.guild_data
		if data.owner_id == user_id then
			error("the owner can't be removed")
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		new_members[key] = nil
		new_data.members = new_members
		if ban then
			const new_banned = table.clone(data.banned)
			new_banned[key] = os.time()
			new_data.banned = new_banned
			const new_invites = table.clone(data.outgoing_invites)
			new_invites[key] = nil
			new_data.outgoing_invites = new_invites
		end
		return new_data
	end
	return try_update_async(guild_store, guild_id, remove_member)
end

return remove_guild_member_async
